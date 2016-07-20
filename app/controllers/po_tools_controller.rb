require 'odbc'

class PoToolsController < ApplicationController
  before_action :require_user, only: [:unlock_po]

  def unlock_po
    @results_msg = []
    @po_number = params[:po_number]

    unless @po_number.blank?
      @po_number.strip!
      @as400_83f = ODBC.connect('as400_tools_f')

      clear_in_use_phhed if po_in_use_in_phhed?
      clear_in_use_pohed if po_in_use_in_pohed?
      clear_in_use_rqhed if po_in_use_in_rqhed?
      clear_records_in_pordt if po_stuck_in_receiver_in_pordt?

      @as400_83f.commit
      @as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">PO Number #{@po_number} was not stuck anywhere.</span>"
      end
    end
  end

  private

  def po_in_use_in_phhed?
    sql = "SELECT painuc, painus FROM phhed 
           WHERE paorid = '#{@po_number}'
             AND (painuc != '' OR painus != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_phhed
    sql = "UPDATE phhed
           SET painuc = '', painus = ''
           WHERE paorid = '#{@po_number}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_number} was in use in PHHED."
  end

  def po_in_use_in_pohed?
    sql = "SELECT phinuc, phinus, phrcpn FROM pohed 
           WHERE phorid = '#{@po_number}'
             AND (phinuc != '' OR phinus != '' OR phrcpn != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_pohed
    sql = "UPDATE pohed
            SET phinuc = '', phinus = '', phrcpn = ''
            WHERE phorid = '#{@po_number}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_number} was in use in POHED or had receipts pending."
  end

  def po_in_use_in_rqhed?
    sql = "SELECT qhinuc, qhinus FROM rqhed 
           WHERE qhorid = '#{@po_number}'
             AND (qhinuc != '' OR qhinus != '')"
    @as400_83f.run(sql).fetch_all
  end

  def clear_in_use_rqhed
    sql = "UPDATE rqhed
           SET qhinuc = '', qhinus = ''
           WHERE qhorid = '#{@po_number}'"
    @as400_83f.run(sql)

    @results_msg << "PO Number #{@po_number} request file was in use in RQHED."
  end

  def po_stuck_in_receiver_in_pordt?
    sql = "SELECT * FROM pordt
           WHERE tdpono = '#{@po_number}'"
    @as400_83f.run(sql).fetch_all
  end

  def clear_records_in_pordt
    sql = "DELETE FROM pordt
           WHERE tdpono = '#{@po_number}'"
    @as400_83f.run(sql)
    
    @results_msg << "PO Number #{@po_number} was stuck in receiver."
  end
end