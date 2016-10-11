require 'odbc'

class PoToolsController < ApplicationController
  before_action :require_user, only: [:po, :unlock_po]

  def po; end
  
  def unlock_po
    @po_num = params[:po_num] if params[:po_num].present?

    if @po_num
      @po_num.strip!
      @results_msg = []
      
      @as400_83f = ODBC.connect('as400_tools_f')

      clear_in_use_phhed if po_in_use_in_phhed?
      clear_in_use_pohed if po_in_use_in_pohed?
      clear_in_use_rqhed if po_in_use_in_rqhed?
      clear_records_in_pordt if po_stuck_in_receiver_in_pordt?

      @as400_83f.commit
      @as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">PO Number #{@po_num} was not stuck anywhere.</span>"
      end
      
      render 'shared/results'
    end
  end

  private

  def po_in_use_in_phhed?
    sql = "SELECT painuc, painus FROM phhed 
           WHERE paorid = '#{@po_num}'
             AND (painuc != '' OR painus != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_phhed
    sql = "UPDATE phhed
           SET painuc = '', painus = ''
           WHERE paorid = '#{@po_num}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_num} was in use in PHHED."
  end

  def po_in_use_in_pohed?
    sql = "SELECT phinuc, phinus, phrcpn FROM pohed 
           WHERE phorid = '#{@po_num}'
             AND (phinuc != '' OR phinus != '' OR phrcpn != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_pohed
    sql = "UPDATE pohed
            SET phinuc = '', phinus = '', phrcpn = ''
            WHERE phorid = '#{@po_num}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_num} was in use in POHED or had receipts pending."
  end

  def po_in_use_in_rqhed?
    sql = "SELECT qhinuc, qhinus FROM rqhed 
           WHERE qhorid = '#{@po_num}'
             AND (qhinuc != '' OR qhinus != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_rqhed
    sql = "UPDATE rqhed
           SET qhinuc = '', qhinus = ''
           WHERE qhorid = '#{@po_num}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_num} request file was in use in RQHED."
  end

  def po_stuck_in_receiver_in_pordt?
    sql = "SELECT * FROM pordt
           WHERE tdpono = '#{@po_num}'"
    @as400_83f.run(sql).fetch_all
  end

  def clear_records_in_pordt
    sql = "DELETE FROM pordt
           WHERE tdpono = '#{@po_num}'"
    @as400_83f.run(sql)
    
    @results_msg << "PO Number #{@po_num} was stuck in receiver."
  end
end