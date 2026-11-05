# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/blend
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/blend"
  version "0.4.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "4abe245690a8bebd0d9d486abfbe0e08b2815be5e09c8e3a367212aebf054484"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "2b084df85958bf3cb8caffadf9ee9078388a49c812367ed937132d04628cee67"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "63a025fbd1002c8473b769e3dff2b32506c9a031ba4b2cf8d83208745af1094d"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "6780ff44077ab39233f40be4be7a669b509478184b6802b500e9606dc6623ee2"
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
