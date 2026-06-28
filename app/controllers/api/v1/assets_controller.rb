module Api
  module V1
    class AssetsController < ApplicationController
      EXTENSIONS = %w[.webp .gif .png .jpg .jpeg .mp4].freeze

      def index
        public_root = Rails.root.join("public")
        pattern     = File.join(public_root, "**", "*")
        paths = Dir.glob(pattern)
          .select { |f| File.file?(f) && EXTENSIONS.include?(File.extname(f).downcase) }
          .map    { |f| "/#{Pathname.new(f).relative_path_from(public_root)}" }
          .sort

        render json: paths
      end
    end
  end
end
