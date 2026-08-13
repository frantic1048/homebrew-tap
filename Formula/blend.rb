# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/Vanilla
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/Vanilla/tree/master/blend"
  version "0.2.13"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "ff94786dd04787ec9f031c344aa6c34c824aaa083394880b4d1978ab25fc332a"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "731024b45a85c285e7da6a9278ab20743d3b780faaae7cd67a7f7dedcc5c7a01"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "08dc269c3b20e4d8b955d55a342452c4d58f1d514cf0b3a1d3166648d7017fb1"
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
