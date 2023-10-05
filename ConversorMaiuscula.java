public class ConversorMaiuscula {
    static {
        System.loadLibrary("maiuscula");
    }

    public native String paraMaiuscula(String texto);

    public static void main(String[] args) {
        ConversorMaiuscula conversor = new ConversorMaiuscula();
        String original = "Olá, Mundo!";
        String maiuscula = conversor.paraMaiuscula(original);

        System.out.println("Original: " + original);
        System.out.println("Maiúscula: " + maiuscula);
    }
}