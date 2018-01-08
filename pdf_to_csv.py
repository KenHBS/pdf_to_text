import os, csv, re
import PyPDF2
from optparse import OptionParser


def pdfs_2_txt(folder):
    pdf_txts = []
    removed_docs = []
    os.chdir(folder)

    files = os.listdir(folder)
    docnames = [x for x in files if ".pdf" in x]
    for docname in docnames:
        print(docname)
        print("----")
        try:
            pdf_txt = pdf_2_txt(docname)
            if len(pdf_txt) > 0:
                pdf_txts.append(pdf_txt)
            else:
                pass
        except (OSError, PyPDF2.utils.PdfReadError) as a:
            os.remove(docname)
            print("Removed %s because of %s" % (docname, a))
            removed_docs.append(docname)
            continue
    print("Removed the following the documents:")
    print(removed_docs)
    return pdf_txts


def pdf_2_txt(docname):
    file = open(docname, 'rb')
    reader = PyPDF2.PdfFileReader(file)

    n = reader.numPages
    pdf_txt = ""
    for i in range(n):
        page = reader.getPage(i)
        page_txt = " " + page.extractText()
        pdf_txt = pdf_txt + page_txt
    file.close()
    return pdf_txt


def clean_text(text):
    pat1 = "https://.*?(?=\\n)"
    pat2 = " American.*?(: [0-9]{1,4})Œ[0-9]{1,4}"
    pat3 = "[^ -~]"
    pat4 = "(\(JEL)+(.*?)\)+"
    patterns = [pat1, pat2, pat3, pat4]
    for pat in patterns:
        text = re.subn(pat, "", text)[0]
    return text


def get_id(text):
    pat = "https://.*?(?=\\n)"
    try:
        return re.findall(pat, text)[0]
    except IndexError:
        return None


def get_jel(text):
    pat = "(?<=JEL )(.*?)(?=\))"
    try:
        jelcodes = re.findall(pat, text)[0]
        return re.subn(",", "", jelcodes)[0]
    except IndexError:
        return None


def main():
    parser = OptionParser()
    parser.add_option("-f", dest="folder",
                      help="absolute folder path with PDF files (required)")
    parser.add_option("-o", dest="opt",
                      help="0: create CSV for each PDF (default)"
                           "1: generates single CSV for the LDA thesis data "
                           "data preparation (including JEL code and DOI "
                           "extraction)",
                      default=0, type=int)
    (options, args) = parser.parse_args()
    if not options.folder:
        parser.error("need to supply folder path (-f)")

    texts = pdfs_2_txt(options.folder)
    if options.opt == 1:
        ids = [get_id(text) for text in texts]
        jels = [get_jel(text) for text in texts]
        texts = [clean_text(text) for text in texts]
        result = list(zip(ids, texts, jels))
        with open(options.docname, 'w') as result_file:
            wr = csv.writer(result_file)
            for line in result:
                wr.writerow(list(line))
    elif options.opt == 0:
        texts = [clean_text(text) for text in texts]
        files = os.listdir(options.folder)
        files = [file for file in files if ".pdf" in file]
        csv_names = [re.sub(".pdf", ".csv", file) for file in files]
        for text, file in zip(texts, csv_names):
            with open(file, 'w') as result_file:
                wr = csv.writer(result_file)
                wr.writerow([text])


if __name__ == "__main__":
    main()
