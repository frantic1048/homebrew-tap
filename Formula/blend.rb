# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/blend
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/blend"
  version "0.3.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "f37ed5dd5cba72d343de04558b8f5be34e0908df37ff5dc47f3b1e6b153b5fe6"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "2833e886922cd61e8ee6942c14963c644b2d065f7f7367a61e48c495c63d0566"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "2bf9992750147f863400953cff257d0d3461d39becb83ed3dd5bd8d47a1ac0d6"
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
