module Parade
  module Renderers

    #
    # With the given HTML content, search for the CSS class for the HTML element
    # and when found generate columns for each element found. The size of the
    # columns is a division of the number of segments.
    #
    class ColumnsRenderer

      attr_accessor :css_class
      attr_accessor :html_element
      attr_accessor :segments

      #
      # @example Creating a ColumnsRenderer
      #
      # Creation of a column renderer that will look for slides with the class
      # 'columns', and create columns out of all h2 elements found, dividing
      # them across 12 elements.
      #
      #     ColumnsRenderer.new(:css_class => 'columns',:html_element => "h2",:segments => 12)
      #
      def initialize(params={})
        params.each {|k,v| send("#{k}=",v) if respond_to? "#{k}=" }
      end

      def render(content)
        html = Nokogiri::XML.fragment(content)

        #for each element with the class 'content.css_class'
        html.css(".content.#{css_class}").each do |slide|

          #chunk and mark nods that are html_element as columns
          chunks = chunk_children_by_element(slide, html_element)

          #remove the current children
          slide.children = ""

          #append the container grid count..size.. thing
          slide['class'] += " container_#{segments}"
          current_column = slide

          #get the number of elements that are html_element
          column_count = chunks.find_all {|is_column, contents| is_column }.count

          chunks.each do |is_column,contents|

            if is_column
              current_column = new_column_div(html, column_count)
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

      def new_column_div(html, column_count)
        column = Nokogiri::XML::Node.new('div',html)
        column['class'] = grid_class(column_count)

        column
      end

      def grid_class column_count
        "grid_#{ segments / column_count }"
      end

    end

  end
end