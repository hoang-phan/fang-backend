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

      def upload_conversation_yml
        file     = params[:file]
        filename = params[:filename].to_s.strip

        return render json: { errors: [ "filename is required" ] }, status: :unprocessable_entity if filename.blank?
        return render json: { errors: [ "file is required" ] }, status: :unprocessable_entity if file.blank?

        unless filename.end_with?(".yml")
          return render json: { errors: [ "filename must end with .yml" ] }, status: :unprocessable_entity
        end

        dest = Rails.root.join("db", "seeds", "conversations", File.basename(filename))
        File.write(dest, file.read.to_s.force_encoding("UTF-8").scrub(""))

        render json: { path: dest.to_s }, status: :ok
      end
    end
  end
end
