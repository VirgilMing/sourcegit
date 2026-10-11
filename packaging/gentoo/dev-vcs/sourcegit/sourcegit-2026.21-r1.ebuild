# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT="10.0"

NUGETS_COMMON="
avalonia.buildservices@11.3.2
azure.ai.openai@2.9.0-beta.1
azure.core@1.51.1
bitmiracle.libtiff.net@2.4.660
communitytoolkit.mvvm@8.4.2
microsoft.bcl.asyncinterfaces@10.0.2
microsoft.dotnet.ilcompiler@10.0.11
microsoft.extensions.configuration.abstractions@10.0.3
microsoft.extensions.dependencyinjection.abstractions@10.0.3
microsoft.extensions.diagnostics.abstractions@10.0.3
microsoft.extensions.fileproviders.abstractions@10.0.3
microsoft.extensions.hosting.abstractions@10.0.3
microsoft.extensions.logging.abstractions@10.0.3
microsoft.extensions.options@10.0.3
microsoft.extensions.primitives@10.0.3
microsoft.net.illink.tasks@10.0.11
microsoft.netcore.app.runtime.nativeaot.linux-x64@10.0.11
onigwrap@1.0.11
openai@2.10.0
pfim@0.11.4
runtime.linux-x64.microsoft.dotnet.ilcompiler@10.0.11
stbimagesharp@2.30.15
system.clientmodel@1.10.0
system.memory.data@10.0.3
textmatesharp.grammars@2.0.4
textmatesharp@2.0.4
"

NUGETS_X11="
avalonia.angle.windows.natives@2.1.25547.20250602
avalonia.controls.datagrid@11.3.13
avalonia.desktop@11.3.22
avalonia.fonts.inter@11.3.22
avalonia.freedesktop@11.3.22
avalonia.native@11.3.22
avalonia.remote.protocol@11.3.18
avalonia.remote.protocol@11.3.22
avalonia.skia@11.3.22
avalonia.themes.fluent@11.3.22
avalonia.win32@11.3.22
avalonia.x11@11.3.22
avalonia@11.3.18
avalonia@11.3.22
harfbuzzsharp.nativeassets.linux@8.3.1.1
harfbuzzsharp.nativeassets.macos@8.3.1.1
harfbuzzsharp.nativeassets.webassembly@8.3.1.1
harfbuzzsharp.nativeassets.win32@8.3.1.1
harfbuzzsharp@8.3.1.1
microcom.runtime@0.11.0
microsoft.build.tasks.git@1.1.1
microsoft.sourcelink.common@1.1.1
microsoft.sourcelink.github@1.1.1
skiasharp.nativeassets.linux@2.88.9
skiasharp.nativeassets.macos@2.88.9
skiasharp.nativeassets.webassembly@2.88.9
skiasharp.nativeassets.win32@2.88.9
skiasharp@2.88.9
tmds.dbus.protocol@0.21.3
"

NUGETS_WAYLAND="
avalonia.angle.windows.natives@2.1.27548.20260419
avalonia.controls.datagrid@12.1.2
avalonia.desktop@12.1.3
avalonia.fonts.inter@12.1.3
avalonia.freedesktop.atspi@12.1.3
avalonia.freedesktop@12.1.3
avalonia.harfbuzz@12.1.3
avalonia.native@12.1.3
avalonia.remote.protocol@12.1.2
avalonia.remote.protocol@12.1.3
avalonia.skia@12.1.3
avalonia.themes.fluent@12.1.3
avalonia.wayland@12.1.3
avalonia.win32@12.1.3
avalonia.x11@12.1.3
avalonia@12.1.2
avalonia@12.1.3
harfbuzzsharp.nativeassets.linux@8.3.1.3
harfbuzzsharp.nativeassets.macos@8.3.1.3
harfbuzzsharp.nativeassets.webassembly@8.3.1.3
harfbuzzsharp.nativeassets.win32@8.3.1.3
harfbuzzsharp@8.3.1.3
microcom.runtime@0.11.6
microsoft.build.tasks.git@10.0.201
microsoft.sourcelink.common@10.0.201
microsoft.sourcelink.github@10.0.201
nwayland@0.11.0
skiasharp.nativeassets.linux@3.119.4
skiasharp.nativeassets.macos@3.119.4
skiasharp.nativeassets.webassembly@3.119.4
skiasharp.nativeassets.win32@3.119.4
skiasharp@3.119.4
system.io.hashing@10.0.5
tmds.dbus.protocol@0.94.1
"

NUGETS="${NUGETS_COMMON} ${NUGETS_X11} ${NUGETS_WAYLAND}"

inherit check-reqs desktop dotnet-pkg-base multiprocessing toolchain-funcs xdg

DESCRIPTION="Open Source Git GUI client using .NET AvaloniaUI"
HOMEPAGE="https://github.com/sourcegit-scm/sourcegit/"
AVALONIA_EDIT_X11="ddf00a91dc0da29b85c79b85c9583860213a99ff"
AVALONIA_EDIT_WAYLAND="358f2c9e4ac57667c0183bf68f8869b110a69b1e"
SRC_URI="
	https://github.com/sourcegit-scm/${PN}/archive/v${PV}.tar.gz -> ${P}.gh.tar.gz
	!wayland? (
		https://github.com/love-linger/AvaloniaEdit/archive/${AVALONIA_EDIT_X11}.tar.gz
			-> AvaloniaEdit-${AVALONIA_EDIT_X11}.snapshot.gh.tar.gz
	)
	wayland? (
		https://github.com/love-linger/AvaloniaEdit/archive/${AVALONIA_EDIT_WAYLAND}.tar.gz
			-> AvaloniaEdit-${AVALONIA_EDIT_WAYLAND}.snapshot.gh.tar.gz
	)
"
for _nuget_uri in ${NUGET_URIS}; do
	_nuget=${_nuget_uri##*/}
	_nuget=${_nuget%.nupkg}
	if has "${_nuget}" ${NUGETS_X11//@/.}; then
		SRC_URI+=" !wayland? ( ${_nuget_uri} )"
	elif has "${_nuget}" ${NUGETS_WAYLAND//@/.}; then
		SRC_URI+=" wayland? ( ${_nuget_uri} )"
	else
		SRC_URI+=" ${_nuget_uri}"
	fi
done
unset _nuget _nuget_uri

LICENSE="MIT Apache-2.0 BSD BSD-2 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE+=" wayland kwin-iconfix"
REQUIRED_USE="elibc_glibc kwin-iconfix? ( wayland )"
RESTRICT="${RESTRICT/strip/}"
QA_PREBUILT="
	usr/lib*/sourcegit/libHarfBuzzSharp.so
	usr/lib*/sourcegit/libSkiaSharp.so
	usr/lib*/sourcegit/libonigwrap.so
"

RDEPEND="
	!dev-vcs/sourcegit-bin
	dev-libs/glib:2
	dev-libs/icu
	dev-libs/openssl:0
	dev-vcs/git
	media-libs/fontconfig
	media-libs/libglvnd
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXfixes
	x11-libs/libXrandr
	virtual/zlib
	wayland? (
		dev-libs/wayland
		x11-libs/libxkbcommon
	)
	kwin-iconfix? (
		dev-qt/qttools:6[qdbus]
		kde-frameworks/kconfig:6
	)
"
DEPEND="virtual/zlib"
BDEPEND="~dev-dotnet/dotnet-sdk-bin-10.0.111:10.0"

CHECKREQS_DISK_BUILD="4G"
CHECKREQS_MEMORY="4G"

pkg_setup() {
	check-reqs_pkg_setup
	if [[ ${MERGE_TYPE} != binary ]]; then
		dotnet-pkg-base_setup
		[[ -x ${DOTNET_PKG_EXECUTABLE} ]] || die ".NET 10 SDK not found"
	fi
}

src_unpack() {
	nuget_link-nuget-archives
	nuget_unpack-non-nuget-archives
	local edit=${AVALONIA_EDIT_X11}
	use wayland && edit=${AVALONIA_EDIT_WAYLAND}
	rmdir "${S}/depends/AvaloniaEdit" || die
	mv "${WORKDIR}/AvaloniaEdit-${edit}" "${S}/depends/AvaloniaEdit" || die
}

src_prepare() {
	if use wayland; then
		unpack "${FILESDIR}/${PN}-${PV}-avalonia12-wayland.patch.xz"
		eapply "${PN}-${PV}-avalonia12-wayland.patch"
		rm "${PN}-${PV}-avalonia12-wayland.patch" || die
	fi
	default
	dotnet-pkg-base_remove-global-json
	nuget_writeconfig "${S}/"

	sed -i "build/resources/_common/applications/${PN}.desktop" \
		-e 's|Exec=/opt/sourcegit/sourcegit|Exec=sourcegit|' \
		-e 's|Icon=/usr/share/icons/sourcegit.png|Icon=sourcegit|' \
		-e 's|Categories=Development$|Categories=Development;RevisionControl;|' || die
	sed -i src/SourceGit.csproj \
		-e "s|git describe --abbrev=8 --dirty|echo v${PVR}|" || die
	sed -i depends/AvaloniaEdit/Directory.Build.props \
		-e '/<TreatWarningsAsErrors>/d' || die
}

src_configure() {
	export DOTNET_CLI_HOME="${T}/dotnet-home"
	edotnet restore src/SourceGit.csproj \
		--configfile "${S}/NuGet.config" \
		--runtime "${DOTNET_PKG_RUNTIME}" \
		-p:Configuration=Release \
		-p:SelfContained=true \
		-p:_IsPublishing=true \
		-p:PublishAot=true \
		-p:PublishAotUsingRuntimePack=true \
		-p:RuntimeFrameworkVersion=10.0.11 \
		-p:DisableUpdateDetection=true \
		-p:DisableTransitiveFrameworkReferenceDownloads=true \
		-p:NuGetAudit=false
}

src_compile() {
	export DOTNET_CLI_HOME="${T}/dotnet-home"
	edotnet publish src/SourceGit.csproj \
		--configuration Release \
		--runtime "${DOTNET_PKG_RUNTIME}" \
		--self-contained true \
		--no-restore \
		--output "${DOTNET_PKG_OUTPUT}" \
		-maxCpuCount:$(makeopts_jobs) \
		-p:PublishAot=true \
		-p:PublishAotUsingRuntimePack=true \
		-p:RuntimeFrameworkVersion=10.0.11 \
		-p:DisableUpdateDetection=true \
		-p:DisableTransitiveFrameworkReferenceDownloads=true \
		-p:DebugType="$(usex debug portable none)" \
		-p:CppCompilerAndLinker="$(tc-getCC)" \
		-p:StripSymbols=false
}

src_install() {
	local dest="/usr/$(get_libdir)/${PN}"
	exeinto "${dest}"
	newexe "${DOTNET_PKG_OUTPUT}/SourceGit" sourcegit
	insinto "${dest}"
	doins "${DOTNET_PKG_OUTPUT}"/lib{HarfBuzzSharp,SkiaSharp,onigwrap}.so
	if use kwin-iconfix; then
		exeinto /usr/libexec/sourcegit
		doexe "${FILESDIR}/sourcegit-kwin-iconfix"
		cat > "${T}/sourcegit" <<-EOF || die
		#!/bin/sh
		"${EPREFIX}/usr/libexec/sourcegit/sourcegit-kwin-iconfix" || :
		exec "${EPREFIX}${dest}/sourcegit" "\$@"
		EOF
		newbin "${T}/sourcegit" sourcegit
	else
		dosym -r "${dest}/sourcegit" /usr/bin/sourcegit
	fi
	doicon -s 256 build/resources/_common/icons/${PN}.png
	domenu build/resources/_common/applications/${PN}.desktop
	einstalldocs
}

pkg_postinst() {
	xdg_pkg_postinst
	if use kwin-iconfix; then
		elog "The SourceGit launcher manages one user-owned KWin icon rule on Wayland."
		elog "Remove only that rule with /usr/libexec/sourcegit/sourcegit-kwin-iconfix --remove."
	fi
}
