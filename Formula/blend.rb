# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/Vanilla
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/Vanilla/tree/master/blend"
  version "0.2.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "7169d077bc06883aec3cf17b645b41936082b0fe3a5b1e2e5c5cb64c3e3e12cd"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "81719a6e0f753d417848b96f7d6ef04d4242e5433d76d3992e1ab51e5c0487ee"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "dda677e0eab044eb6bc593152e393c2322144378f99d781456c442baaf8ea2ed"
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
