class Byobu < Formula
  desc "Text-based window manager and terminal multiplexer"
  homepage "https://github.com/dustinkirkland/byobu"
  url "https://github.com/dustinkirkland/byobu/archive/refs/tags/7.20.tar.gz"
  sha256 "aa2563a0567f2c74e62d03b4a07bf7f1f005c88e8cf8007194c873c770371931"
  version "7.20"
  license "GPL-3.0-only"

  head "https://github.com/dustinkirkland/byobu.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "newt"
  depends_on "tmux"

  on_macos do
    depends_on "coreutils"
    depends_on "gettext"
  end

  conflicts_with "ctail", because: "both install `ctail` binaries"

  def install
    cp "./debian/changelog", "./ChangeLog"
    system "autoreconf", "--force", "--install", "--verbose"
    system "./configure", *std_configure_args
    system "make"
    ENV.deparallelize { system "make", "install" }

    byobu_python = Formula["newt"].deps
                                  .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                  .to_formula
                                  .libexec/"bin/python"

    lib.glob("byobu/include/*.py").each do |script|
      byobu_script = "byobu-#{script.basename(".py")}"

      libexec.install(bin/byobu_script)
      (bin/byobu_script).write_env_script(libexec/byobu_script, BYOBU_PYTHON: byobu_python)
    end
  end

  test do
    system bin/"byobu-status"
    assert_match "open terminal failed", shell_output("#{bin}/byobu-select-session 2>&1", 1)
  end
end
