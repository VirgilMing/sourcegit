# SourceGit 2026.21-r1 for gentoo-zh

[简体中文说明](README.zh_CN.md)

This package builds upstream tag `v2026.21`
(`a4ae633c51c922150ea113913c682a8213308560`) as Native AOT on amd64/glibc.
It uses the existing `dev-dotnet/dotnet-sdk-bin-10.0.111:10.0` build dependency.
There is no SDK ebuild or system SDK modification in this submission.

## Validation scope

Only amd64/glibc has been validated. The ebuild keeps `KEYWORDS="~amd64"`
and the `elibc_glibc` requirement; it does not offer verified musl support.
Musl adaptation and build/runtime validation remain for contributors using
that environment. The current AOT runtime packs and private native libraries
must be checked before relaxing the libc requirement.

The full pkgcheck scan still reports `RequiredUseDefaults` and
`RequiredUseUnsatisfiableInDev` for amd64 musl profiles because of this
requirement. These findings remain visible; no musl build was performed.

## USE flags

| Flags | Framework and behavior |
| --- | --- |
| `-wayland -kwin-iconfix` | Avalonia 11.3.22 and AvaloniaEdit `ddf00a91`; X11 backend |
| `wayland -kwin-iconfix` | Downstream Avalonia 12.1.3 migration and AvaloniaEdit `358f2c9e`; native Wayland when `WAYLAND_DISPLAY` is set, X11 otherwise |
| `wayland kwin-iconfix` | The same native build plus a launcher helper for KWin icons |

`kwin-iconfix` requires `wayland`. The inherited `debug` flag retains native debug
information. Neither feature has a `+` default; desktop profiles can still
enable `wayland`.

The framework migration is downstream: upstream SourceGit has not accepted
<https://github.com/sourcegit-scm/sourcegit/pull/2768>. The compressed patch is
based on the release tag, not later `develop` changes. Both AvaloniaEdit sources
are immutable commits available from the configured public upstream fork.

## Dependencies and offline builds

Both variants use the same .NET 10.0.11 AOT compiler and runtime packs.
Their closures contain 26 common NuGets, 29 additional NuGets for Avalonia 11,
and 34 additional NuGets for Avalonia 12. Conditional `SRC_URI` selects only the
required set and submodule source. Restore uses declared distfiles and a fresh
cache. The system SDK's runtime-NuGet `PDEPEND` is unchanged: this only reduces
SourceGit's application dependency list.

The installed application needs no .NET runtime. It consists of
`/usr/lib64/sourcegit/sourcegit` and three private native libraries, plus the
command, desktop entry and icon. Package-managed update detection is disabled.

## KWin icon compatibility

With `kwin-iconfix`, the launcher invokes a compatibility helper as the launching
user. It only acts on Wayland when `org.kde.KWin` is already present on the
session bus, creates one fixed-ID rule matching `sourcegit`, and associates it
with `sourcegit.desktop`. It preserves other rules and repeated launches do
not create duplicate rules. Root and non-KWin sessions are skipped.

Portage does not edit user configuration. The generated rule is user-owned and
remains after disabling the USE flag or uninstalling. Remove only the helper's
rule as that user before removing the helper:

```sh
/usr/libexec/sourcegit/sourcegit-kwin-iconfix --remove
```

Existing manually created SourceGit rules have different IDs and are preserved.
No 1Password rule is included.

## Development and validation

This directory is a development overlay. Copy `dev-vcs/sourcegit/` into the
submission repository and add its version-tracking entry there. Manual bumps
are needed because the framework patch and NuGet lists require verification.

On amd64/glibc, isolated Portage builds with a fresh NuGet cache completed
through the install-image phase for X11, Wayland, and Wayland with
`kwin-iconfix`. Startup checks covered opening a repository on X11 and Wayland
and opening Blame on Wayland. These are brief startup checks, not a long-term
performance or exhaustive interaction test.

The regression checks use real KConfig tools with an isolated configuration:

```sh
python3 tests/kwin_iconfix_test.py
```

Keep isolated Portage build/install-image checks separate from a dependency-
resolving `emerge` and real merge. Development checks can use the verified SDK
through a temporary Portage hook; that hook is not part of the ebuild. A real
merge uses the declared system SDK dependency.

Keep AOT diagnostics visible. DataGrid emits an existing `IL3053` in both
framework versions. SourceGit uses explicit template columns with automatic
column generation and user sorting disabled.
