# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/Vanilla
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/Vanilla/tree/master/blend"
  version "0.2.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "af9fa0606d21e377bd441cb4ae8295450d6d9fe38546d6d64a1741197eb5626e"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "f06e9ea608adfba27c4ea32057822b16a3b5378940f6b641a6bfc2cf26f07d91"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "6c881ce40c6937eb47d794bc6f51cd02200c4dc7797b9b8d3513ee615a3ae24a"
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
