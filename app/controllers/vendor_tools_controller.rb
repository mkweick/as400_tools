require 'odbc'

class VendorToolsController < ApplicationController
  before_action :require_user

  def unlock_vendor
    @results_msg = []
    @vendor_num = params[:vendor_num]
    
    unless @vendor_num.blank?
      @vendor_num = @vendor_num.strip.upcase
      @as400_83f = ODBC.connect('as400_tools_f')

      sql = "SELECT a.avinus, b.pvinus FROM apven AS a
             JOIN vendr AS b ON b.pvvnno = a.avvnno
             WHERE a.avvnno = '#{@vendor_num}'"
      vendor = @as400_83f.run(sql).fetch_all

      if vendor
        in_use = vendor.flatten.map(&:strip)

        unless in_use[0].blank? #file apven
          sql = "UPDATE apven SET avinus = '' WHERE avvnno = '#{@vendor_num}'"
          @as400_83f.run(sql)

          @results_msg << "Vendor number #{@vendor_num} cleared from use in APVEN."
        end
        
        unless in_use[1].blank? #file vendr
          sql = "UPDATE vendr SET pvinus = '' WHERE pvvnno = '#{@vendor_num}'"
          @as400_83f.run(sql)

          @results_msg << "Vendor number #{@vendor_num} cleared from use in VENDR."
        end
      end

      @as400_83f.commit
      @as400_83f.disconnect

      if @results_msg.empty?
        @results_msg << "<span id=\"good\">Vendor Number #{@vendor_num} was " \
                        "not in use in APVEN or VENDR.</span>"
      end
    end
  end
end