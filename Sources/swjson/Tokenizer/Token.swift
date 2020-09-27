

public enum Token {
    case BEGIN_OBJECT
    case END_OBJECT
    case BEGIN_ARRAY
    case END_ARRAY
    case NULL
    case NUMBER(Double)
    case STRING(String)
    case BOOLEAN(Bool)
    case SEP_COLON
    case SEP_COMMA
    case END_DOCUMENT
}
