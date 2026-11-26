# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/blend
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/blend"
  version "0.4.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "42d5e105ba17fb383b91409785d2e037b3bccc7a3b55d8a565dae374a28f1bdd"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "e362b1e5a16dc0c4d4ee9fb98d02c721c4d0578c40358b8f97493886d7ba1b46"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "fffc75c10e2db539f0fef7f4be601e4d0428064c32caf6f78797249e6c4ba6c8"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "f6c0368956669a41b01ca19cb70c5660b3bf8d209e604a9de076c65a99e76e89"
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
