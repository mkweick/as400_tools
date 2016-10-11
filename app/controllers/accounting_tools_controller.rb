require 'odbc'

class AccountingToolsController < ApplicationController
  before_action :require_user

  def voucher_group_id; end
  
  def unlock_voucher_group_id
    @voucher_group_id = params[:voucher_group_id] if params[:voucher_group_id].present?
    
    if @voucher_group_id
      @voucher_group_id = @voucher_group_id.strip.upcase
      @results_msg = []
      
      as400_83f = ODBC.connect('as400_tools_f')

      sql = "SELECT vggid5, vggrst, vginus FROM apvgp
             WHERE vggid5 = '#{@voucher_group_id}'
               AND (vggrst != '' OR vginus != '')"
      voucher_group_id = as400_83f.run(sql).fetch_all

      if voucher_group_id
        sql = "UPDATE apvgp
               SET vggrst = '', vginus = ''
               WHERE vggid5 = '#{@voucher_group_id}'"
        as400_83f.run(sql)

        @results_msg << "Voucher Group ID #{@voucher_group_id} cleared from use in APVGP."
      end

      as400_83f.commit
      as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">Voucher Group ID #{@voucher_group_id} was " \
                        "not in use in APVGP.</span>"
      end
      
      render 'shared/results'
    end
  end
end