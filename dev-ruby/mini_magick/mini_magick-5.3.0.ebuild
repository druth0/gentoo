# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33 ruby34"

RUBY_FAKEGEM_RECIPE_TEST="rspec3"
RUBY_FAKEGEM_EXTRADOC="README.md"

RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem

DESCRIPTION="Manipulate images with minimal use of memory"
HOMEPAGE="https://github.com/minimagick/minimagick"
SRC_URI="https://github.com/minimagick/minimagick/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RUBY_S="minimagick-${PV}"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="test"

# It's only used at runtime in this case because this extension only
# _calls_ the commands. But when we run tests we're going to need tiff
# and jpeg support at a minimum.
RDEPEND="media-gfx/imagemagick"
DEPEND="test? ( virtual/imagemagick-tools[jpeg,png,tiff] )"

ruby_add_rdepend "
	dev-ruby/benchmark
	dev-ruby/logger
"

ruby_add_bdepend "test? ( dev-ruby/mocha dev-ruby/webmock )"

all_ruby_prepare() {
	# remove executable bit from all files
	find "${S}" -type f -exec chmod -x {} +

	sed -i -e '/bundler/ s:^:#:' spec/spec_helper.rb || die

	# Don't force a specific formatter but use overall Gentoo defaults
	# and show all failures.
	sed -i -e '/config.\(fail_fast\|formatter\)/ s:^:#:' spec/spec_helper.rb || die

	# Avoid broken spec that does not assume . in path name
	sed -i -e '/reformats a layer/,/end/ s:^:#:' spec/lib/mini_magick/image_spec.rb || die

	# Avoid spec broken by recent imagemagick updates
	sed -i -e '/reads exif/askip "Now returns more complete EXIF data"' spec/lib/mini_magick/image_spec.rb || die
}
