module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: %i[show update destroy]

      def index
        @items = Item.all.order(:name)
        render json: @items.map { |i| serialize_item(i) }
      end

      def show
        render json: serialize_item(@item)
      end

      def create
        @item = Item.new(item_params)
        @item.enhancements_list = params.dig(:item, :enhancements) || []

        if @item.save
          render json: serialize_item(@item), status: :created
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        @item.assign_attributes(item_params)
        @item.enhancements_list = params.dig(:item, :enhancements) if params.dig(:item, :enhancements)

        if @item.save
          render json: serialize_item(@item)
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
        head :no_content
      end

      private

      def set_item
        @item = Item.find(params[:id])
      end

      def item_params
        params.expect(item: [ :slug, :name, :icon, :category, :quality,
                               :base_damage, :base_defense ])
      end

      def serialize_item(item)
        h = {
          id:           item.slug,
          name:         item.name,
          icon:         item.icon,
          category:     item.category,
          quality:      item.quality,
          enhancements: item.enhancements_list
        }
        h[:baseDamage]  = item.base_damage  unless item.base_damage.nil?
        h[:baseDefense] = item.base_defense unless item.base_defense.nil?
        h
      end
    end
  end
end
