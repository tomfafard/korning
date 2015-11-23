# Use this file to import the sales information into the
# the database.

require "pg"
require 'csv'
require 'pry'

system 'psql korning < schema.sql'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

@sales = []
@employees = []
@customers = []
@products = []
@frequencies = []

CSV.foreach("sales.csv", headers: true, header_converters: :symbol) do |row|
  sale = row.to_hash
  @sales << sale
end

# row[0] = row[0].gsub(/[()]/, "").split.each_slice(2).map{|a| a.join ' '}
# row[1] = row[1].gsub(/[()]/, "").split.each_slice(1).map{|a| a.join ' '}

@sales.each do |sale|
  @employees << sale[:employee]
  @employees.uniq!
  @customers << sale[:customer_and_account_no]
  @customers.uniq!
  @products << sale[:product_name]
  @products.uniq!
  @frequencies << sale[:invoice_frequency]
  @frequencies.uniq!
end


@employees.each do |employee|
  db_connection do |conn|
    conn.exec_params("
      INSERT INTO employee_table (name) VALUES ($1);", ["#{employee}"])
  end
end

@customers.each do |customer|
  db_connection do |conn|
    conn.exec_params("
      INSERT INTO customer_table (customer) VALUES ($1);", ["#{customer}"])
  end
end

@products.each do |product|
  db_connection do |conn|
    conn.exec_params("
      INSERT INTO product_table (product) VALUES ($1);", ["#{product}"])
  end
end

@frequencies.each do |frequency|
  db_connection do |conn|
    conn.exec_params("
      INSERT INTO frequency_table (frequency) VALUES ($1);", ["#{frequency}"])
  end
end

@sales.each do |sale|
  db_connection do |conn|
    employee_id = conn.exec_params("SELECT id FROM employee_table WHERE ($1) = employee_table.name", ["#{sale[:employee]}"])
    product_id = conn.exec_params("SELECT id FROM product_table WHERE ($1) = product_table.product", ["#{sale[:product_name]}"])
    customer_id = conn.exec_params("SELECT id FROM customer_table WHERE ($1) = customer_table.customer", ["#{sale[:customer_and_account_no]}"])
    frequency_id = conn.exec_params("SELECT id FROM frequency_table WHERE ($1) = frequency_table.frequency", ["#{sale[:invoice_frequency]}"])

    conn.exec_params("
      INSERT INTO invoice_table (employee_id, product_id, customer_id, frequency_id, invoice_no, sale_date, sale_amount, units_sold)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8);",
      ["#{employee_id[0]["id"]}","#{product_id[0]["id"]}","#{customer_id[0]["id"]}","#{frequency_id[0]["id"]}", "#{sale[:invoice_no]}", "#{sale[:sale_date]}", "#{sale[:sale_amount]}","#{sale[:units_sold]}"])
  end
end
