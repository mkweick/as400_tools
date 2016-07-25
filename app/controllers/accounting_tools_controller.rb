require 'odbc'

class AccountingToolsController < ApplicationController
  before_action :require_user

  def unlock_voucher_group_id
    @results_msg = []
    @ws_id = params[:ws_id]
    
    unless @ws_id.blank?
      @ws_id = @ws_id.strip.upcase
      as400_83f = ODBC.connect('as400_tools_f')

      sql = "SELECT vggid5, vggrst, vginus FROM apvgp
             WHERE vggid5 = '#{@ws_id}'
               AND (vggrst != '' OR vginus != '')"
      voucher_group_id = as400_83f.run(sql).fetch_all

      if voucher_group_id
        sql = "UPDATE apvgp
               SET vggrst = '', vginus = ''
               WHERE vggid5 = '#{@ws_id}'"
        as400_83f.run(sql)

        @results_msg << "Voucher Group ID #{@ws_id} cleared from use in APVGP."
      end

      as400_83f.commit
      as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">Voucher Group ID #{@ws_id} was " \
                        "not in use in APVGP.</span>"
      end
    end
  end
end