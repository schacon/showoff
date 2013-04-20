module Parade
  module Renderers

    #
    # With the given HTML content, search for the CSS class for the HTML element
    # and when found the first of the elements will be contained in a smaller
    # column on the left and the remaining elements will be contained in
    # a larger container on the right.
    #
    class ContentWithCaptionRenderer

      attr_accessor :css_class
      attr_accessor :html_element
      #attr_accessor :segments

      #
      # @example Creating a ContentWithCaptionRenderer
      #
      # Creation of a column renderer that will look for slides with the class
      # 'content-with-caption', and create a smaller column with the first of
      # the h2 elements on the left and a larger column on the right that
      # contains all remaining h2 elements
      #
      #     ContentWithCaptionElement.new(:css_class => 'content-with-caption',:html_element => "h2",:segments => 12)
      #
      def initialize(params={})
        params.each {|k,v| send("#{k}=",v) if respond_to? "#{k}=" }
      end

      def render(content)
        html = Nokogiri::XML.fragment(content)

        html.css(".content.#{css_class}").each do |slide|

          chunks = chunk_children_by_element(slide, html_element)

          slide.children = ""

          slide['class'] += " columns container_12"
          current_column = slide
          is_first_h2 = true
          is_second_h2 = true

          column_count = chunks.find_all {|is_column, contents| is_column }.count

          chunks.each do |is_column,contents|

            if is_column && is_first_h2
              current_column = new_column_div(html, 4)
              is_first_h2 = false
            elsif is_column && is_second_h2
              current_column = new_column_div(html, 8)
              is_second_h2 = false
            end

            contents.each {|content| current_column.add_child content }
            slide.add_child current_column unless current_column == slide

          end

        end

        html.to_s

      end

      private

      def chunk_children_by_element slide, html_element
        chunks = slide.children.chunk {|child| child.name == html_element }
      end

      def new_column_div(html, column_span)
        column = Nokogiri::XML::Node.new('div',html)
        column['class'] = grid_class(column_span)

        column
      end

      def grid_class column_span
        "grid_#{ column_span}"
      end

    end

  end
end