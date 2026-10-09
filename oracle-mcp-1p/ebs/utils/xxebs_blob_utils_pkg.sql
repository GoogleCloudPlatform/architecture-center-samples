
    
CREATE OR REPLACE PACKAGE xxebs_blob_utils_pkg AS
    /*
    -- =========================================================================
    -- Package Name : xxebs_blob_utils_pkg
    -- Description  : Convert FND_LOBS BLOB files into Base64 CLOB format.
    -- =========================================================================
    */

    -- Procedure to convert FND_LOBS attachment to Base64 CLOB
    PROCEDURE convert_blob_to_base64 (
        p_file_id      IN  NUMBER,
        x_base64_clob  OUT CLOB,
        x_status       OUT VARCHAR2,
        x_message      OUT VARCHAR2
    );

END xxebs_blob_utils_pkg;
/

CREATE OR REPLACE PACKAGE BODY xxebs_blob_utils_pkg AS

    PROCEDURE convert_blob_to_base64 (
        p_file_id      IN  NUMBER,
        x_base64_clob  OUT CLOB,
        x_status       OUT VARCHAR2,
        x_message      OUT VARCHAR2
    ) IS
        l_blob        BLOB;
        l_len         INTEGER;
        l_pos         INTEGER := 1;
        l_amount      INTEGER := 2382; -- Multiple of 3 required for Base64 boundary alignment
        l_buffer      RAW(2382);
        l_encoded_raw RAW(32767);
    BEGIN
        -- Default output status
        x_status  := 'S';
        x_message := 'Success';

        -- Parameter validation
        IF p_file_id IS NULL THEN
            x_status  := 'E';
            x_message := 'File ID parameter cannot be NULL.';
            RETURN;
        END IF;

        -- Fetch BLOB from FND_LOBS
        SELECT file_data
          INTO l_blob
          FROM fnd_lobs
         WHERE file_id = p_file_id;

        IF l_blob IS NULL OR DBMS_LOB.getlength(l_blob) = 0 THEN
            x_status  := 'E';
            x_message := 'BLOB data for File ID ' || p_file_id || ' is empty or NULL.';
            RETURN;
        END IF;

        -- Initialize temporary CLOB
        DBMS_LOB.createtemporary(x_base64_clob, TRUE);
        l_len := DBMS_LOB.getlength(l_blob);

        -- Convert BLOB to Base64 CLOB in chunks
        WHILE l_pos <= l_len LOOP
            -- Adjust chunk size for the final chunk
            IF l_pos + l_amount - 1 > l_len THEN
                l_amount := l_len - l_pos + 1;
            END IF;

            -- Read chunk from BLOB
            DBMS_LOB.read(l_blob, l_amount, l_pos, l_buffer);

            -- Base64 Encode RAW chunk
            l_encoded_raw := UTL_ENCODE.base64_encode(l_buffer);

            -- Append to result CLOB
            DBMS_LOB.append(
                dest_lob => x_base64_clob,
                src_lob  => UTL_I18N.raw_to_char(l_encoded_raw, 'AL32UTF8')
            );

            l_pos := l_pos + l_amount;
        END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_status  := 'E';
            x_message := 'File ID ' || p_file_id || ' not found in FND_LOBS.';
            IF DBMS_LOB.isopen(x_base64_clob) = 1 THEN
                DBMS_LOB.freetemporary(x_base64_clob);
            END IF;
            x_base64_clob := NULL;

        WHEN OTHERS THEN
            x_status  := 'E';
            x_message := 'Unexpected Error: ' || SQLERRM;
            IF DBMS_LOB.isopen(x_base64_clob) = 1 THEN
                DBMS_LOB.freetemporary(x_base64_clob);
            END IF;
            x_base64_clob := NULL;
    END convert_blob_to_base64;

END xxebs_blob_utils_pkg;
/
