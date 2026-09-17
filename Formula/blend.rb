# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/blend
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/blend"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "49f0dee3d51f08681767165dd3f615d9bb9885e1298741cbdd55c635a7832f68"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "89269e3d841992afe6fa37235f9f911d367dd2531fc1c1682d3518f2380b7390"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "295e43fef125fdc07fcdb5f073793139e1180117ecb424790455e3aecf0e25c3"
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
