package org.example.JSON;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.serialization.DeserializationSchema;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.example.DTO.Transaction;
import java.io.IOException;

public class JSONDeserializerTransaction implements org.apache.flink.api.common.serialization.DeserializationSchema<org.example.DTO.Transaction> {

    private ObjectMapper mapper = new ObjectMapper();

    @Override
    public void open(InitializationContext context) throws Exception {
        DeserializationSchema.super.open(context);
    }

    @Override
    public Transaction deserialize(byte[] bytes) throws IOException {
        return mapper.readValue(bytes, Transaction.class);
    }

    @Override
    public boolean isEndOfStream(Transaction transaction) {
        return false;
    }

    @Override
    public TypeInformation<Transaction> getProducedType() {
        return TypeInformation.of(Transaction.class);
    }
}
