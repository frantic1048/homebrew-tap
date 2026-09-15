# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/Vanilla
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/Vanilla/tree/master/blend"
  version "0.2.16"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "f0be9e9ca0ace046b23ac398ce3851b6d4c6d4bdf340f05a2b36096f5e61181c"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "96df940a80f4b9c69c0aed45e42b3751cdd507512ce9473ab301564b5971e64b"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "1bb31c7797b6cf45964f9de1533cc25d01d898715133c3b1edf23546d9ed0991"
    else
      odie "blend is not available for this architecture"
    end
  end

  livecheck do
    url :stable
    regex(/^blend-v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install Dir["*/blend"].first || "blend"
  end

  test do
    assert_match "blend #{version}", shell_output("#{bin}/blend --version")
  end
end
