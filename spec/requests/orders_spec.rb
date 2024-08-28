require 'rails_helper'

RSpec.describe "OrdersControllers", type: :request do
  describe "GET orders_path (/index)" do
    it "renders the index view" do
      orders = FactoryBot.create_list(:order, 10)
      get orders_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:orders)).to eq(orders)
    end
  end

  describe "GET order_path (/show)" do
    it "renders the :show template" do
      order = FactoryBot.create(:order)
      get order_path(id: order.id)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns(:order)).to eq(order)
    end
    it "redirects to the index path if the order id is invalid" do
      get order_path(id: 5000) # an ID that doesn't exist
      expect(response).to redirect_to orders_path
    end
  end

  describe "GET new_order_path (/new)" do
    it "renders the :new template" do
      get new_order_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe "GET edit_order_path (/edit)" do
    it "renders the :edit template" do
      order = FactoryBot.create(:order)
      get edit_order_path(order)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
      expect(assigns(:order)).to eq(order)
    end
  end

  describe "POST orders_path with valid data (/create)" do
    it "saves a new entry and redirects to the show path for the entry" do
      customer = FactoryBot.create(:customer)
      order_attributes = FactoryBot.attributes_for(:order, customer_id: customer.id)
      expect {
        post orders_path, params: { order: order_attributes }
      }.to change(Order, :count).by(1)
      expect(response).to redirect_to order_path(id: Order.last.id)
      expect(assigns(:order)).to be_a(Order)
      expect(assigns(:order)).to be_persisted
    end
  end

  describe "POST orders_path with invalid data" do
    it "does not save a new entry or redirect" do
      order_attributes = FactoryBot.attributes_for(:order)
      order_attributes.delete(:product_name)
      expect {
        post orders_path, params: { order: order_attributes }
      }.to_not change(Order, :count)
      expect(response).to render_template(:new)
    end
  end

  describe "PUT order_path with valid data (/update)" do
    it "updates an entry and redirects to the show path for the order" do
      customer = FactoryBot.create(:customer)
      order = FactoryBot.create(:order)
      put "/orders/#{order.id}", params: {order: {product_count: 50}}
      order.reload
      expect(order.product_count).to eq(50)
      expect(response).to redirect_to("/orders/#{order.id}")
    end
  end

  describe "PUT order_path with invalid data" do
    it "does not update the customer record or redirect" do
      order = FactoryBot.create(:order)
      put "/orders/#{order.id}", params: {order: {customer_id: 5001}}
      order.reload
      expect(order.customer_id).not_to eq(5001)
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE delete a order record (/destroy)" do
    it "deletes a order record" do
      order = FactoryBot.create(:order)
      expect {
        delete order_path(order)
      }.to change(Order, :count).by(-1)
      expect(response).to redirect_to(orders_path)
    end
  end

  describe "DELETE customer with associated orders" do
    it "does not delete the customer and shows a flash message when the customer has orders" do
      customer = FactoryBot.create(:customer)
      order = FactoryBot.create(:order, customer: customer)
      expect {
        delete customer_path(customer.id)
      }.to_not change(Customer, :count)
      expect(flash[:notice]).to eq("That customer record could not be deleted, because the customer has orders.")
      expect(response).to redirect_to customers_path
    end
  end
end
