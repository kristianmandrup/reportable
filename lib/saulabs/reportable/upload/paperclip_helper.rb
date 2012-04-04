module Saulabs
  module Reportable
    module Upload
      module PaperclipHelper
        # use with Paperclip
        def create
          @asset ||= ::Asset.new(params[:asset])

          @asset.assetable_type = params[:assetable_type]
          @asset.assetable_id = params[:assetable_id] || 0
          
          # generate random guid
          @asset.guid = params[:guid] || 6.times.inject("") {|res, i| res << guid_range.sample.to_s }
          
          @asset.data = Saulabs::Reportable::Upload::QqFile.parse(params[:qqfile], request)
          @asset.user_id = 0
          @success = @asset.save

          respond_with(@asset) do |format|
            format.html { render :text => "{'success':#{@success}}" }
            format.xml { render :xml => @asset.to_xml }
            format.js { render :text => "{'success':#{@success}}"}
            format.json { render :json => {:success => @success} }
          end
        end

        protected

        def guid_range
          @guid_range ||= (0..9).to_a + ('A'..'Z').to_a
        end
      end
    end
  end
end