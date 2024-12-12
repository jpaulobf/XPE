package org.example.DTO;

import org.apache.flink.api.common.functions.ReduceFunction;

public class AmountReduce implements ReduceFunction<Transaction> {
    @Override
    public Transaction reduce(Transaction in1, Transaction in2) {
        return new Transaction(
                in1.getTransactionId(), in1.getProductId(), in1.getProductName(), in1.getProductCategory(), in1.getProductPrice(), in1.getProductQuantity(),
                in1.getProductBrand(), in1.getCurrency(), in1.getCustomerId(), in1.getTransactionDate(), in1.getPaymentMethod(), in1.getTotalAmount() + in2.getTotalAmount());
    }
}