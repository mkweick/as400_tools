require 'odbc'

class PoToolsController < ApplicationController
  before_action :require_user, only: [:unlock_po]

  def unlock_po
    @results_msg = []
    @po_number = params[:po_number]
    
    unless @po_number.blank?
      @po_number.strip!
      @as400_83f = ODBC.connect('as400_tools_f')

      unlock_in_use_purchase_order_pohed
      purchace_order_request_field
      purchase_order_receipts_pending
      purchase_order_receiver_in_use
      purchase_order_stuck_in_receiver
      purchase_order_stuck_in_reciver_second_check    
      unlock_in_use_purchase_order_phhed

      @as400_83f.commit
      @as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good-po\">PO Number #{@po_number} was not stuck anywhere.</span>"
      end
    end
  end

  private

  def unlock_in_use_purchase_order_pohed
    sql_check_po = "SELECT phinuc, phinus FROM pohed 
                    WHERE phorid = '#{@po_number}' 
                      AND (phinuc != '' OR phinus != '')"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all   

    unless purchase_order.nil?
      sql_update_po = "UPDATE pohed SET phinuc = '', phinus = ''
                       WHERE phorid = '#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} was in use in POHED."
    end
  end

  def purchace_order_request_field
    sql_check_po = "SELECT qhinuc, qhinus FROM rqhed 
                    WHERE qhorid = '#{@po_number}' 
                      AND (qhinuc != '' OR qhinus != '')"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all   

    unless purchase_order.nil?
      sql_update_po = "UPDATE rqhed SET qhinuc = '', qhinus = ''
                       WHERE qhorid = '#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} request file was in use in RQHED."
    end
  end

  def purchase_order_receipts_pending
    sql_check_po = "SELECT phrcpn FROM pohed 
                    WHERE phorid = '#{@po_number}' AND phrcpn != ''"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all   

    unless purchase_order.nil?
      sql_update_po = "UPDATE pohed SET phrcpn = '' WHERE phorid = '#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} had receipts pending."
    end
  end

  def purchase_order_receiver_in_use
    sql_check_po = "SELECT thinus FROM porhd 
                    WHERE thrcvr LIKE '%#{@po_number}' AND thinus != ''"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all

    unless purchase_order.nil?
      sql_update_po = "UPDATE porhd SET thinus = '' WHERE thrcvr LIKE '%#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} receiver was in use."
    end
  end

  def purchase_order_stuck_in_receiver
    sql_check_po = "SELECT * FROM pordt WHERE tdrcvr LIKE '%#{@po_number}'"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all

    unless purchase_order.nil?
      sql_update_po = "DELETE FROM pordt WHERE tdrcvr LIKE '%#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} was stuck in receiver."
    end
  end

  def purchase_order_stuck_in_reciver_second_check
    sql_check_po = "SELECT * FROM pordt WHERE tdpono = '#{@po_number}'"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all

    unless purchase_order.nil?
      sql_update_po = "DELETE FROM pordt WHERE tdpono = '#{@po_number}'"
      @as400_83f.run(sql_update_po)
      
      @results_msg << "PO Number #{@po_number} was stuck in receiver."
    end
  end

  def unlock_in_use_purchase_order_phhed
    sql_check_po = "SELECT painuc, painus FROM phhed 
                    WHERE paorid = '#{@po_number}' 
                      AND (painuc != '' OR painus != '')"

    stmt_check_po = @as400_83f.run(sql_check_po)
    purchase_order = stmt_check_po.fetch_all   

    unless purchase_order.nil?
      sql_update_po = "UPDATE phhed SET painuc = '', painus = ''
                       WHERE paorid = '#{@po_number}'"
      @as400_83f.run(sql_update_po)

      @results_msg << "PO Number #{@po_number} was in use in PHHED."
    end
  end
end