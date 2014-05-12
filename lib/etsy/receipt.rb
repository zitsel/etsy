module Etsy
  class Receipt
    include Etsy::Model

    attributes :receipt_id, :order_id, :seller_user_id, :buyer_user_id, :name, :first_line, :second_line, :city, :state, :zip, :country_id, :payment_method, :payment_email, :message_from_seller, :message_from_buyer, :was_paid, :total_tax_cost, :total_price, :total_shipping_cost, :currency_code, :message_from_payment, :was_shipped, :buyer_email, :seller_email, :discount_amt, :subtotal, :grandtotal, :shipments
    attribute :created, :from => :creation_tsz
    attribute :modified, :from => :last_modified_tsz
    attribute :currency, :from => :currency_code
    

    def self.get(id, options = {})
      options.merge!(:require_secure => true)
      get("/receipts/#{id}", options)
    end

    def self.find_all_by_status(shop_id, status, options = {})
      get_all("/shops/#{shop_id}receipts/#{status}", options)
    end
  end
end