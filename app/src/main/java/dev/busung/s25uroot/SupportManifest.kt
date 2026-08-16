package dev.busung.s25uroot

import org.json.JSONArray
import org.json.JSONObject

data class RemoteArtifact(
    val url: String,
    val size: Long,
    val sha256: String? = null,
)

data class TargetProfile(
    val profileId: String,
    val displayName: String,
    val models: Set<String>,
    val kernelVersions: Set<String>,
    val exploit: RemoteArtifact,
    val kernelSu: RemoteArtifact,
    val kernelReleases: Set<String> = emptySet(),
    val buildTokens: Set<String> = emptySet(),
) {
    init {
        require(models.isNotEmpty()) { "Payload must support at least one model" }
        require(kernelVersions.isNotEmpty()) { "Payload must support at least one kernel version" }
    }

    fun matchesDevice(snapshot: DeviceSnapshot): Boolean =
        models.any { it.equals(snapshot.model, ignoreCase = true) }

    fun matchesKernelVersion(snapshot: DeviceSnapshot): Boolean =
        snapshot.kernelVersion in kernelVersions

    fun matchesKernelRelease(snapshot: DeviceSnapshot): Boolean =
        kernelReleases.isEmpty() || snapshot.kernelRelease in kernelReleases

    fun matchesBuildToken(snapshot: DeviceSnapshot): Boolean {
        if (buildTokens.isEmpty()) return true
        val haystack = listOf(snapshot.buildId, snapshot.fingerprint, snapshot.kernelRelease)
            .joinToString(" ")
        return buildTokens.any { token -> haystack.contains(token, ignoreCase = true) }
    }

    fun matches(snapshot: DeviceSnapshot): Boolean =
        matchesDevice(snapshot) &&
            matchesKernelVersion(snapshot) &&
            matchesKernelRelease(snapshot) &&
            matchesBuildToken(snapshot)

    val supportedModels: String
        get() = models.joinToString()

    val supportedKernelVersions: String
        get() = kernelVersions.joinToString()
}

data class SupportManifest(
    val schemaVersion: Int,
    val targets: List<TargetProfile>,
) {
    companion object {
        fun parse(bytes: ByteArray): SupportManifest {
            val root = JSONObject(bytes.toString(Charsets.UTF_8))
            val schemaVersion = root.getInt("schemaVersion")
            require(schemaVersion == 3) { "Unsupported support manifest schema" }
            val payloadsJson = root.getJSONArray("payloads")
            val payloads = buildList {
                for (index in 0 until payloadsJson.length()) {
                    val payload = payloadsJson.getJSONObject(index)
                    val exploit = payload.getJSONObject("exploit")
                    val kernelSu = payload.getJSONObject("kernelsu")
                    add(
                        TargetProfile(
                            profileId = payload.getString("payloadId"),
                            displayName = payload.getString("displayName"),
                            models = payload.getJSONArray("models").strings(),
                            kernelVersions = payload.getJSONArray("kernelVersions").strings(),
                            exploit = RemoteArtifact(
                                url = exploit.getString("url"),
                                size = exploit.getLong("size"),
                                sha256 = exploit.optString("sha256").ifBlank { null },
                            ),
                            kernelSu = RemoteArtifact(
                                url = kernelSu.getString("url"),
                                size = kernelSu.getLong("size"),
                                sha256 = kernelSu.optString("sha256").ifBlank { null },
                            ),
                            kernelReleases = payload.optJSONArray("kernelReleases").orEmptyStrings(),
                            buildTokens = payload.optJSONArray("buildTokens").orEmptyStrings(),
                        ),
                    )
                }
            }
            return SupportManifest(schemaVersion, payloads)
        }

        private fun JSONArray.strings(): Set<String> = buildSet {
            for (index in 0 until length()) add(getString(index))
        }

        private fun JSONArray?.orEmptyStrings(): Set<String> =
            this?.strings().orEmpty()
    }
}
