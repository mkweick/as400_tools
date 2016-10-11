require 'odbc'

class ItemToolsController < ApplicationController
  before_action :require_user

  def whs_item; end
  
  def unlock_whs_item
    @item_num = params[:item_num] if params[:item_num].present?
    @whs_id = params[:whs_id] if params[:whs_id].present?
    
    if @item_num && @whs_id
      @item_num = @item_num.strip.upcase
      @results_msg = []
      
      as400_83f = ODBC.connect('as400_tools_f')

      sql = "SELECT ibitno FROM itbal
             WHERE ibitno = '#{@item_num}'
               AND ibwhid = '#{@whs_id}'
               AND ibinus != ''"
      item_found = as400_83f.run(sql).fetch_all

      if item_found
        sql = "UPDATE itbal
               SET ibinus = ''
               WHERE ibitno = '#{@item_num}'
                 AND ibwhid = '#{@whs_id}'"
        as400_83f.run(sql)

        @results_msg << "Item number #{@item_num} in WHS #{@whs_id} cleared from in use."
      end

      as400_83f.commit
      as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">Item Number #{@item_num} in WHS #{@whs_id} was not in use.</span>"
      end
      
      render 'shared/results'
    end
  end
end
