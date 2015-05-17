require 'rmagick'
require 'tempfile'
require 'csv'

module CountingSemaphore
  class Image

    COLORS            = %w(red blue green)
    DEFAULT_TOLERANCE = 25

    class << self
      def folder_to_csv(folder:, tolerance: nil)
        tolerance ||= DEFAULT_TOLERANCE
        raise "Folder does not exist: #{ folder }" unless File.exists?(folder)
        CSV.open('results.csv', 'w') do |csv|
          csv << headers
          Dir["#{ folder }/**/*"].each do |file|
            unless File.directory?(file)
              image = Image.new(file, tolerance)
              csv << image.to_csv
            end
          end
        end
      end

      private

      def headers
        [ 'File name' ].tap do |array|
          COLORS.each do |color|
            array << "Total #{ color } pixels"
            (COLORS - [ color ]).each do |alt_color|
              array << "Total #{ color } over #{ alt_color }"
            end
          end
        end
      end
    end

    attr_reader :name, :channel_images, :tolerance

    def initialize(name, tolerance)
      @name      = name
      @tolerance = tolerance
      create_channel_images
    end

    def to_csv
      comparison = compare
      comparison.keys.each_with_object([name]) do |color, array|
        present_pixels = comparison[color].select{|k,v| v['present'] }
        array << present_pixels.count
        (COLORS - [color]).each do |alt_color|
          array << present_pixels.select{|k,v| v[alt_color] }.count
        end
      end
    end

    private

    def compare
      result = {}
      channel_images.each do |color, image|
        color_result = {}
        image.each_pixel do |pixel, col, row|
          pixel_result = {}
          pixel_result['present'] = not_black_pixel?(pixel)
          compare_with            = channel_images.keys - [ color ]
          compare_with.each do |compare_color|
            compare_pixel = channel_images[compare_color].get_pixels(col, row, 1, 1).first
            pixel_result[compare_color] = not_black_pixel?(compare_pixel)
          end
          color_result["#{col}x#{row}"] = pixel_result
        end
        result[color] = color_result
      end
      result
    end

    def black_pixel?(pixel)
      pixel.red < tolerance || pixel.blue < tolerance || pixel.green < tolerance
    end

    def not_black_pixel?(pixel)
      !black_pixel?(pixel)
    end

    def create_channel_images
      @channel_images = COLORS.each_with_object({}) do |color, hash|
        channel_image = image.channel(eval("Magick::#{ color.capitalize }Channel"))
        tempfile      = Tempfile.new("#{ name.split('/').last }_#{ color }")
        channel_image.write(tempfile.path)
        hash.merge!(color => channel_image)
      end
    end

    def image_depth
      @image_depth ||= image.depth
    end

    def image
      @image ||= Magick::Image.read(name).first.tap do |_image|
        _image.colorspace = Magick::RGBColorspace
      end
    end
  end
end
