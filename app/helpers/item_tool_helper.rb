require 'odbc'

module ItemToolHelper
  
  def as400_warehouses
    as400_83f = ODBC.connect('as400_tools_f')

    sql = "SELECT SUBSTRING(ccctlk,6,7) FROM orctl 
           WHERE ccctlk LIKE 'WHSNU%'"
    warehouses = as400_83f.run(sql).fetch_all.flatten

    as400_83f.commit
    as400_83f.disconnect

    warehouses
  end
end