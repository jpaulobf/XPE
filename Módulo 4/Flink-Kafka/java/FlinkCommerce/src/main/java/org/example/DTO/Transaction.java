package org.example.DTO;

import java.sql.Timestamp;

public class Transaction {

    String transactionId;
    String productId;
    String productName;
    String productCategory;
    double productPrice;
    int productQuantity;
    String productBrand;
    String currency;
    String customerId;
    Timestamp transactionDate;
    String paymentMethod;
    double totalAmount;

    public Transaction() {
    }

    public Transaction(String transactionId, String productId, String productName, String productCategory, double productPrice, int productQuantity, String productBrand, String currency, String customerId, Timestamp transactionDate, String paymentMethod, double totalAmount) {
        this.transactionId = transactionId;
        this.productId = productId;
        this.productName = productName;
        this.productCategory = productCategory;
        this.productPrice = productPrice;
        this.productQuantity = productQuantity;
        this.productBrand = productBrand;
        this.currency = currency;
        this.customerId = customerId;
        this.transactionDate = transactionDate;
        this.paymentMethod = paymentMethod;
        this.totalAmount = totalAmount;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductCategory() {
        return productCategory;
    }

    public void setProductCategory(String productCategory) {
        this.productCategory = productCategory;
    }

    public double getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(double productPrice) {
        this.productPrice = productPrice;
    }

    public int getProductQuantity() {
        return productQuantity;
    }

    public void setProductQuantity(int productQuantity) {
        this.productQuantity = productQuantity;
    }

    public String getProductBrand() {
        return productBrand;
    }

    public void setProductBrand(String productBrand) {
        this.productBrand = productBrand;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    @Override
    public String toString() {
        return "Transaction{" +
                "transactionId='" + transactionId + '\'' +
                ", productId='" + productId + '\'' +
                ", productName='" + productName + '\'' +
                ", productCategory='" + productCategory + '\'' +
                ", productPrice=" + productPrice +
                ", productQuantity=" + productQuantity +
                ", productBrand='" + productBrand + '\'' +
                ", currency='" + currency + '\'' +
                ", customerId='" + customerId + '\'' +
                ", transactionDate=" + transactionDate +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", totalAmount=" + totalAmount +
                '}';
    }
}
