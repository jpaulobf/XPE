package org.example.DTO;

import java.sql.Timestamp;

public class SalesTransaction {

    private Timestamp salesTransactionId;
    private String productCategory;
    private double totalAmount;

    public SalesTransaction() {
    }

    public SalesTransaction(Timestamp salesTransactionId, String productCategory, double totalAmount) {
        this.salesTransactionId = salesTransactionId;
        this.productCategory = productCategory;
        this.totalAmount = totalAmount;
    }

    public Timestamp getSalesTransactionId() {
        return salesTransactionId;
    }

    public void setSalesTransactionId(Timestamp salesTransactionId) {
        this.salesTransactionId = salesTransactionId;
    }

    public String getProductCategory() {
        return productCategory;
    }

    public void setProductCategory(String productCategory) {
        this.productCategory = productCategory;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    @Override
    public String toString() {
        return "SalesTransaction {" +
                "salesTransactionId='" + salesTransactionId + '\'' +
                ", productCategory='" + productCategory + '\'' +
                ", totalAmount=" + totalAmount +
                '}';
    }
}