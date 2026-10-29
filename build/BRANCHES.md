# SourceGit feature branches and integration

The common upstream base for this snapshot is develop commit
`6b677688a3f85ec10e6e6c94287140a22c0b4597` (2026-10-30).

| Branch | Parent | Responsibility |
| --- | --- | --- |
| `codex/sourcegit-tab-drag-feedback` (A) | develop | Avalonia 11 tab drag preview, target feedback, insertion indicator, cleanup and tests |
| `codex/sourcegit-avalonia12` (B) | the same develop commit | Avalonia 12.1.4 API/XAML migration, AvaloniaEdit/SDK/dependencies, migration documentation and menu shortcut layout fix |
| `codex/sourcegit-wayland` (C) | B | Official Avalonia.Wayland 12.1.4 and conditional native Wayland selection; X11 when WAYLAND_DISPLAY is absent |
| `codex/sourcegit-wayland-tab-drag` (D) | merge of C and A | Rebuildable packaging integration and any adaptations required only by the combination |

B contains the changes originally committed as `cd11627b`, `0255678d` and
`c2fb24df`, in that order. C adds only the change from `7e3bb57c`. A contains
the change from `53d3c354`. These commits have been replayed onto the new common
base. D uses a real merge so A's commit is shared, rather than copied.

There are currently no integration-only production code adaptations. Keep
Avalonia 11/12 shared drag fixes in A and migration fixes in B. Put a future fix
in D only if it is needed specifically by the combination, and document it here.
The only current D-specific changes are integration and test instructions.

The downstream Wayland version override from `a0da7cca` is excluded. All four
branches use their official framework packages. The independent Avalonia
cursor-shape patch and historical local r2 package remain separate work.
The historical r2 source (`1d8e5270`) is preserved by the backup tag
`backup/sourcegit-split-20261029-211908/sourcegit-wayland-ui-integration`;
its obsolete branch and validation worktree can be removed.

## Rebuild and preserve the inputs

Keep A and B on the same develop commit. Rebase A independently, then update B
and rebase C above it. B -> C is the only local gh-stack; D is an ordinary Git
integration branch. Do not put D in the linear stack. For each package refresh,
pin D's full SHA, AvaloniaEdit gitlink and archive checksums, and create a dated
packaging tag. Superseded private tags and archives may be retired after the
replacement is installed and verified. Do not silently retarget inputs still
consumed by another package.

From a clean worktree, use a new integration branch name for each rebuild:

```sh
git switch -c integration-next codex/sourcegit-wayland
git merge --no-ff codex/sourcegit-tab-drag-feedback
# Reapply the D-specific documentation and any recorded combination-only fixes.
# Validate, then advance the integration branch and create a new packaging tag.
```

The Gentoo ebuild must pin the full D SHA, the AvaloniaEdit gitlink and the
exported archive checksums. Local package revision r3 uses the official
Avalonia.Wayland 12.1.4 NuGet without a backend-version MSBuild property. Any
future cursor patch must be an explicit, separately recorded packaging layer.

## Validate each layer

Initialize the pinned AvaloniaEdit submodule before building. Use .NET SDK 10.
On A, run:

```sh
python3 tests/TabDragFeedback/run.py --avalonia-version 11.3.22
```

On B, build and run the application with X11. On D, run:

```sh
python3 tests/TabDragFeedback/run.py --avalonia-version 12.1.4
dotnet publish src/SourceGit.csproj -c Release -r linux-x64
```

The fixture covers four headless rendering/lifecycle cases. Independently check
real pointer drag feedback, reordering and Escape cancellation on both X11 and
native Wayland. For C/D, unset WAYLAND_DISPLAY while keeping a valid DISPLAY to
check X11 selection, and use a valid WAYLAND_DISPLAY to check native Wayland.
A nonempty but invalid WAYLAND_DISPLAY selects Wayland and is not an automatic
connection-failure fallback to X11.

Verify Gentoo Manifest/QA/pretend and an offline Native AOT build separately.
Build, headless, native interaction and installed-package results are distinct;
previous r1/r2 runtime results do not validate a rebuilt snapshot. Keep the
DataGrid AOT warnings described in [README.md](README.md) visible.
