require 'saulabs/reportable/config'

module Saulabs

  module Reportable

    module ReportTagHelper

      def report_img_server_upload dom_id, options = {:path = 'reportable/img_upload', :format => :png}
          %Q{var canvasData = testCanvas.toDataURL("image/#{format}");
var ajax = new XMLHttpRequest();
ajax.open("POST",'#{path}',false);
ajax.setRequestHeader('Content-Type', 'application/upload');
ajax.send(canvasData );
        }
      end

      # Will save image or return <img> element variable (default: save)
      # Options:
      #   - type (report type, either google, raphael, or flot - default: raphael)
      #   - format (image format (mime code) - default: png)
      #   - as_element (create and return <img> element - default: false)
      #   - scale (true|false)
      #   - width (for scaling)
      #   - height (for scaling)
      #   - img_var (var name to use for image element returned - override default: oImg_[format]_[type])
      def report_to_image options = {:type => :raphael, :format => :png}
        options = report_options(options)
        canvas2img options[:dom_id], options
      end

      # will prompt the user to save the image as PNG.
      # Options:
      #   - type (report type, either google, raphael, or flot - default: raphael)
      #   - format (image format (mime code) - default: png)
      #   - scale (true|false)
      #   - width (for scaling)
      #   - height (for scaling)
      def report_to_img_save options = {:type => :raphael, :format => :png}
        options = report_options(options)
        canvas2img options[:dom_id], options.merge(:as_element => false)
      end

      # Will return the image variable name for the image as an <img> element
      # Options:
      #   - type (report type, either google, raphael, or flot - default: raphael)
      #   - format (image format (mime code) - default: png)
      #   - scale (true|false)
      #   - width (for scaling)
      #   - height (for scaling)
      def report_to_img_var options = {:type => :raphael, :img => :png}
        options = report_options(options)
        canvas2img options[:dom_id], options.merge(:as_element => true)
      end
        
      # Renders a sparkline with the given data using the google drawing api.
      #
      # @param [Array<Array<DateTime, Float>>] data
      #   an array of report data as returned by {Saulabs::Reportable::Report#run}
      # @param [Hash] options
      #   options for the sparkline
      #
      # @option options [Fixnum] :width (300)
      #   the width of the generated image
      # @option options [Fixnum] :height (34)
      #   the height of the generated image
      # @option options [String] :line_color ('0077cc')
      #   the line color of the generated image
      # @option options [String] :fill_color ('e6f2fa')
      #   the fill color of the generated image
      # @option options [Array<Symbol>] :labels ([])
      #   the axes to render lables for (Array of +:x+, +:y+, +:r+, +:t+; this is x axis, y axis, right, top)
      # @option options [String] :alt ('')
      #   the alt attribute for the generated image
      # @option options [String] :title ('')
      #   the title attribute for the generated image
      #
      # @return [String]
      #   an image tag showing a sparkline for the passed +data+
      #
      # @example Rendering a sparkline tag for report data
      #
      #   <%= google_report_tag(User.registrations_report, :width => 200, :height => 100, :color => '000') %>
      #
      def google_report_tag(data, options = {})
        options.reverse_merge!(Config.google_options)

        Saulabs::Reportable.last_report_options[:google] = options

        data = data.to_a.collect { |d| d[1] }
        labels = ''
        unless options[:labels].empty?
          chxr = {}
          options[:labels].each_with_index do |l, i|
            chxr[l] = "#{i}," + ([:x, :t].include?(l) ? "0,#{data.length}" : "#{[data.min, 0].min},#{data.max}")
          end
          labels = "&chxt=#{options[:labels].map(&:to_s).join(',')}&chxr=#{options[:labels].collect{|l| chxr[l]}.join('|')}"
        end
        title = ''
        unless options[:title].blank?
          title = "&chtt=#{options[:title]}"
        end
        image_tag(
          "http://chart.apis.google.com/chart?cht=ls&chs=#{options[:width]}x#{options[:height]}&chd=t:#{data.join(',')}&chco=#{options[:line_color]}&chm=B,#{options[:fill_color]},0,0,0&chls=1,0,0&chds=#{data.min},#{data.max}#{labels}#{title}",
          :alt   => options[:alt],
          :title => options[:title]
        )
      end

    
      # Renders a sparkline with the given data using Raphael.
      #
      # @param [Array<Array<DateTime, Float>>] data
      #   an array of report data as returned by {Saulabs::Reportable::Report#run}
      # @param [Hash] options
      #   options for width, height, the dom id and the format
      # @param [Hash] raphael_options
      #   options that are passed directly to Raphael as JSON
      #
      # @option options [Fixnum] :width (300)
      #   the width of the generated graph
      # @option options [Fixnum] :height (34)
      #   the height of the generated graph
      # @option options [Array<Symbol>] :dom_id ("reportable_#{Time.now.to_i}")
      #   the dom id of the generated div
      #
      # @return [String]
      #   an div tag and the javascript code showing a sparkline for the passed +data+
      #
      # @example Rendering a sparkline tag for report data
      #
      #   <%= raphael_report_tag(User.registrations_report, { :width => 200, :height => 100, :format => 'div(100).to_i' }, { :vertical_label_unit => 'registrations' }) %>
      #
      def raphael_report_tag(data, options = {}, raphael_options = {})
        @__raphael_report_tag_count ||= -1
        @__raphael_report_tag_count += 1
        default_dom_id = "#{data.model_name.downcase}_#{data.report_name}#{@__raphael_report_tag_count > 0 ? @__raphael_report_tag_count : ''}"
        options.reverse_merge!(Config.raphael_options.slice(:width, :height, :format))
        options.reverse_merge!(:dom_id => default_dom_id)
        raphael_options.reverse_merge!(Config.raphael_options.except(:width, :height, :format))

        Saulabs::Reportable.last_report_options[:raphael] = options

        %Q{<div id="#{options[:dom_id]}" style="width:#{options[:width]}px;height:#{options[:height]}px;"></div>
        <script type="text\/javascript" charset="utf-8">
          var graph = Raphael('#{options[:dom_id]}');
          graph.g.linechart(
            -10, 4, #{options[:width]}, #{options[:height]},
            #{(0..data.to_a.size).to_a.to_json},
            #{data.to_a.map { |d| d[1].send(:eval, options[:format]) }.to_json},
            #{raphael_options.to_json}
          ).hover(function() {
            this.disc = graph.g.disc(this.x, this.y, 3).attr({fill: "#{options[:hover_fill_color]}", stroke: '#{options[:hover_line_color]}' }).insertBefore(this);
            this.flag = graph.g.flag(this.x, this.y, this.value || "0", 0).insertBefore(this);
            if (this.x + this.flag.getBBox().width > this.paper.width) {
              this.flag.rotate(-180);
              this.flag.translate(-this.flag.getBBox().width, 0);
              this.flag.items[1].rotate(180);
              this.flag.items[1].translate(-5, 0);
            }
          }, function() {
            this.disc.remove();
            this.flag.remove();
          });
        </script>}
      end
          
      # Renders a sparkline with the given data using the jquery flot plugin.
      #
      # @param [Array<Array<DateTime, Float>>] data
      #   an array of report data as returned by {Saulabs::Reportable::Report#run}
      # @param [Hash] options
      #   options for width, height, the dom id and the format
      # @param [Hash] flot_options
      #   options that are passed directly to Raphael as JSON
      #
      # @option options [Fixnum] :width (300)
      #   the width of the generated graph
      # @option options [Fixnum] :height (34)
      #   the height of the generated graph
      # @option options [Array<Symbol>] :dom_id ("reportable_#{Time.now.to_i}")
      #   the dom id of the generated div
      #
      # @return [String]
      #   an div tag and the javascript code showing a sparkline for the passed +data+
      #
      # @example Rendering a sparkline tag for report data
      #
      #   <%= flot_report_tag(User.registrations_report) %>
      #

      def flot_report_tag(data, options = {}, flot_options = {})
        @__flot_report_tag_count ||= -1
        @__flot_report_tag_count += 1
        default_dom_id = "#{data.model_name.downcase}_#{data.report_name}#{@__flot_report_tag_count > 0 ? @__flot_report_tag_count : ''}"
        options.reverse_merge!(Config.flot_options.slice(:width, :height, :format))
        options.reverse_merge!(:dom_id => default_dom_id)
        flot_options.reverse_merge!(Config.flot_options.except(:width, :height, :format))

        Saulabs::Reportable.last_report_options[:flot] = options

        %Q{<div id="#{options[:dom_id]}" style="width:#{options[:width]}px;height:#{options[:height]}px;"></div>
        <script type="text\/javascript" charset="utf-8">
        $(function() {
          var set = #{data.to_a.map{|d| d[1] }.to_json},
          data = [];
          for (var i = 0; i < set.length; i++) {
            data.push([i, set[i]]);
          }
          $.plot($('##{options[:dom_id]}'), [data], #{flot_options.to_json});
        });
        </script>}
      end

      protected

      def canvas2img dom_id, options = {:format => :png)
        insert_as_element = options[:as_element] || false
        scale = options[:scale] || 'false'
        scaling = ',' + [options[:width], options[:height]].join(',') if scale == true

        img_var = options[:img_var] || "oImg_#{format}_#{options[:type]}" if insert_as_element
        lside = img_var ? "var #{img_var} = " : ''

        script = %Q{var oCanvas = document.getElementById('#{dom_id}');
#{lside} Canvas2Image.saveAs#{options[:img].to_s.upcase}(oCanvas, #{insert_as_element}#{scaling});
}
        img_var ? img_var : script
      end

      # return options with dom_id of Canvas element of last report
      def report_options options = {:type => :raphael, :img => :png}
        raise ArgumentError, "Invalid report type, must be one of #{valid_reportable_types}, was #{options[:type]}" unless valid_reportable_type?(options[:type]) 
        report_type = options[:type] || :raphael
        last_report_options = Saulabs::Reportable.last_report_options[report_type]

        raise "No report could be found for #{report_type}" if last_report_options.empty?

        dom_id = last_report_options[:dom_id]
        options.merge!(:dom_id => dom_id, :width => last_report_options[:width], :height => last_report_options[:height])
        options
      end

      def valid_reportable_type? type
        valid_reportable_types.include?(type.to_sym)
      end

      def valid_reportable_types
        [:raphael, :flot, :google]
      end    
    end
  end

end
