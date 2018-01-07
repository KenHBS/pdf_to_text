# From PDF to text 
This code takes a folder with PDFs and saves the text in the PDF as CSV (either seperately, or all at once)

## Usage
Prequisites is a version of python with PyPDF2 (version 1.5.3).

```
$ python3 pdf_to_csv.py --help

Usage: pydevconsole.py [options]
Options:
  -h, --help  show this help message and exit
  -f FOLDER   absolute folder path with PDF files (required)
  -o OPT      0: create CSV for each PDF (default)
              1: generates single CSV for the LDA
                    thesis data data preparation (including JEL code and DOI extraction)

```

## Example
If the PDF files are located at `/Users/Ken/MyPDFs`, then:

```
$ python3 pdf_to_csv.py -f /Users/Ken/MyPDFs
```

## Note
The option `opt=1` is a special use case I needed for [my thesis](https://github.com/KenHBS/LDA_thesis) on [Latent Dirichlet Allocation](https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation). 
This option is possibly useless to everybody else. 

