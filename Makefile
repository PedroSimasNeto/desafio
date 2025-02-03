# Nome do arquivo zip que será gerado
ZIP_FILE_GLUE = utils.zip
ZIP_FILE_LAMBDA = infra/lambda.zip
GLUE_SCRIPT = app/glue/src/main.py

# Diretório de onde os arquivos serão compactados
SOURCE_DIR_GLUE = app/glue/utils
SOURCE_DIR_LAMBDA = app/lambda

# Nome do bucket S3
S3_BUCKET = s3://s3-script-desafio

# Regra principal para criar o arquivo .zip
all: $(ZIP_FILE_GLUE) $(ZIP_FILE_LAMBDA) upload

# Regra para gerar o zip
$(ZIP_FILE_GLUE):
	@echo "Compactando arquivos de $(SOURCE_DIR_GLUE) para $(ZIP_FILE_GLUE)"
	zip -r $(ZIP_FILE_GLUE) $(SOURCE_DIR_GLUE)

$(ZIP_FILE_LAMBDA):
	@echo "Compactando arquivos de $(SOURCE_DIR_GLUE) para $(ZIP_FILE_LAMBDA)"
	zip -r $(ZIP_FILE_LAMBDA) $(SOURCE_DIR_LAMBDA)

# Regra para fazer o upload para o S3
upload:
	@echo "Enviando $(ZIP_FILE_GLUE) e $(GLUE_SCRIPT) para o bucket $(S3_BUCKET)"
	aws s3 cp $(ZIP_FILE_GLUE) $(S3_BUCKET)/
	aws s3 cp $(GLUE_SCRIPT) $(S3_BUCKET)/

# Limpeza dos arquivos gerados
clean:
	@echo "Removendo o arquivo $(ZIP_FILE_GLUE)"
	rm -f $(ZIP_FILE_GLUE)
	@echo "Removendo o arquivo $(ZIP_FILE_LAMBDA)"
	rm -f $(ZIP_FILE_LAMBDA)

.PHONY: all clean
