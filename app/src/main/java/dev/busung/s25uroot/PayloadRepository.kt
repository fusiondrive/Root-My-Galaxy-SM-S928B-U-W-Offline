package dev.busung.s25uroot

import android.content.Context
import android.system.Os
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest

data class VerifiedPayloads(
    val profile: TargetProfile,
    val exploit: File,
    val kernelSu: File,
)

class PayloadRepository(private val context: Context) {
    fun loadTargets(): List<TargetProfile> {
        val manifestBytes = context.assets.open("targets-v3.json").use { input ->
            input.readBytes()
        }
        return SupportManifest.parse(manifestBytes).targets
    }

    fun resolveTarget(snapshot: DeviceSnapshot): TargetProfile = loadTargets()
        .firstOrNull { it.matches(snapshot) }
        ?: error(context.getString(R.string.repo_no_profile))

    fun resolveTarget(profileId: String): TargetProfile = loadTargets()
        .firstOrNull { it.profileId == profileId }
        ?: error(context.getString(R.string.repo_profile_missing, profileId))

    fun download(profile: TargetProfile, onProgress: (String) -> Unit): VerifiedPayloads {
        val directory = File(context.filesDir, "payloads/${profile.profileId}").apply { mkdirs() }
        val exploit = extractBundled(
            profile.exploit,
            directory,
            onProgress,
            context.getString(R.string.artifact_exploit_bundled),
        )
        val kernelSu = extractBundled(
            profile.kernelSu,
            directory,
            onProgress,
            context.getString(R.string.artifact_kernelsu_bundled),
        )
        Os.chmod(exploit.absolutePath, 0b100100100)
        Os.chmod(kernelSu.absolutePath, 0b100100100)
        return VerifiedPayloads(profile, exploit, kernelSu)
    }

    private fun extractBundled(
        artifact: RemoteArtifact,
        directory: File,
        onProgress: (String) -> Unit,
        label: String,
    ): File {
        val assetPath = assetPath(artifact.url)
        val destination = File(directory, File(assetPath).name)
        if (destination.exists() && !destination.delete()) {
            val alt = File(directory, "${destination.name}.${System.currentTimeMillis()}.tmp")
            return writeAsset(assetPath, artifact, alt, label, onProgress)
        }
        return writeAsset(assetPath, artifact, destination, label, onProgress)
    }

    private fun writeAsset(
        assetPath: String,
        artifact: RemoteArtifact,
        destination: File,
        label: String,
        onProgress: (String) -> Unit,
    ): File {
        val digest = MessageDigest.getInstance("SHA-256")
        var total = 0L
        FileOutputStream(destination).use { output ->
            context.assets.open(assetPath).use { input ->
                val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    total += count
                    require(total <= artifact.size) {
                        context.getString(R.string.repo_size_exceeded, label)
                    }
                    digest.update(buffer, 0, count)
                    output.write(buffer, 0, count)
                }
                output.fd.sync()
            }
        }
        require(total == artifact.size) { context.getString(R.string.repo_incomplete, label) }
        val actualSha256 = digest.digest().joinToString("") { "%02x".format(it) }
        require(artifact.sha256 == null || artifact.sha256 == actualSha256) {
            context.getString(R.string.repo_hash_mismatch, label)
        }
        onProgress(label)
        return destination
    }

    private fun assetPath(url: String): String {
        require(url.startsWith(ASSET_PREFIX)) { context.getString(R.string.repo_url_invalid) }
        val path = url.removePrefix(ASSET_PREFIX)
        require(path.isNotBlank() && !path.startsWith("/") && ".." !in path.split('/')) {
            context.getString(R.string.repo_url_invalid)
        }
        return path
    }

    companion object {
        private const val ASSET_PREFIX = "asset://"
    }
}
