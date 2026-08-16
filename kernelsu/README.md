# Samsung KernelSU late-load builds

The files in this directory are built from KernelSU `v3.2.5`, commit
`b0bc817b4e966aa6aa830834eaf6ef765d821d40`. They are not interchangeable
between firmware releases.

## Bundled artifacts

| File | Target | KMI | Size | SHA-256 |
| --- | --- | --- | ---: | --- |
| `android14-6.1_kernelsu-e3q-S928USQS6DZF2-kdp.ko` | `SM-S928U` / `SM-S928U1`, `S928USQS6DZF2` | `android14-6.1` | 400,152 | `ed7afea6cd221d5698739d3a1633264c084ffb77f2df730e5808941e0a555de5` |
| `ksud-e3q-S928USQS6DZF2-kdp` | Same exact U/U1 DZF2 build | `android14-6.1` | 4,998,352 | `10c1bf87f8e475e6ab8c5d1c5a085aa1544ee091f4451ad65141ea75261ab610` |
| `android14-6.1_kernelsu-e3q-S928BXXS6DZF2-kdp.ko` | `SM-S928B`, `S928BXXS6DZF2` | `android14-6.1` | 398,432 | `14f805c6a03123e84f10a252eb5b47f6c65c56c05ad4ccccf1f836c6867f64a9` |
| `ksud-e3q-S928BXXS6DZF2-kdp` | Same exact S928B DZF2 build | `android14-6.1` | 4,748,232 | `43f451313dc111429187f8f93e76c57c42976323782aac936c1c09aa309b76b3` |

The standalone `.ko` files are retained for auditing. The app late-loads the
matching `ksud-*` binary because `ksud late-load` embeds the target
`<kmi>_kernelsu.ko` asset.

Do not reuse the U/U1 pair on `SM-S928B`, and do not reuse the B pair on
`SM-S928U` / `SM-S928U1`. The two kernels share BTF and most symbol offsets,
but they have different vermagic strings and a different
`SLIDE_NFULNL_LOGGER_OFF`.
