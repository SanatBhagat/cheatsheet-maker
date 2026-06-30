import sys
import os
import fitz 
from weasyprint import HTML, CSS
import google.generativeai as genai

def extract_text(pdf_path):
    try:
        doc = fitz.open(pdf_path)
        text = ""
        for page in doc:
            text += page.get_text()
        return text.strip()
    except Exception as e:
        print(f"Error reading PDF: {e}", file=sys.stderr)
        sys.exit(1)

def condense_with_ai(text):
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not set.", file=sys.stderr)
        sys.exit(1)
        
    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are an expert utility engine that creates micro-cheatsheets.
    Take the following text and condense it down to the absolute minimum words.
    
    Rules:
    - Use heavy abbreviations, shorthand, and relational symbols (->, =, &).
    - Remove all conversational filler and grammar.
    - Format strictly using HTML definition lists: <dl> wrapper, <dt> for concept, <dd> for answer.
    - Return ONLY valid inner HTML content. No markdown fences.
    
    Source Material:
    {text[:12000]}
    """
    
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        return response.text
    except Exception as e:
        print(f"AI Error: {e}", file=sys.stderr)
        sys.exit(1)

def compile_to_pdf(html_content, output_path):
    micro_css = """
    @page { size: A4; margin: 4mm; }
    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 4.5pt; line-height: 1.05; column-count: 4; column-gap: 2mm; margin: 0; padding: 0; }
    dl { margin: 0; padding: 0; }
    dt { font-weight: bold; margin-top: 2px; border-bottom: 0.3px solid #666; page-break-inside: avoid; }
    dd { margin-left: 1mm; margin-bottom: 3px; page-break-inside: avoid; word-wrap: break-word; }
    """
    
    document = f"<!DOCTYPE html><html><head><style>{micro_css}</style></head><body>{html_content}</body></html>"
    
    try:
        HTML(string=document).write_pdf(output_path, stylesheets=[CSS(string=micro_css)])
    except Exception as e:
        print(f"Compilation Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3: sys.exit(1)
    raw_text = extract_text(sys.argv[1])
    if not raw_text: sys.exit(1)
    ai_output = condense_with_ai(raw_text)
    compile_to_pdf(ai_output, sys.argv[2])
    print("SUCCESS")
