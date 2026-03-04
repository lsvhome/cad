#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path
from llm_client import LLMClient
from config import Config

class OpenSCADModifier:
    def __init__(self):
        self.config = Config()
        self.llm_client = LLMClient(self.config)
        self.input_dir = Path("/app/input")
        self.output_dir = Path("/app/output")
        
    def read_or_create_scad(self, filename=None):
        """Read existing .scad file or create a new one"""
        if filename:
            scad_path = self.input_dir / filename
            if scad_path.exists() and scad_path.suffix == '.scad':
                print(f"Reading existing file: {scad_path}")
                with open(scad_path, 'r') as f:
                    return f.read(), scad_path.stem
            else:
                print(f"File not found: {scad_path}")
                return None, None
        else:
            print("No file provided, creating new SCAD file")
            return self.create_default_scad(), "generated"
    
    def create_default_scad(self):
        """Create a default OpenSCAD template"""
        return """// Default OpenSCAD file
// A simple cube
cube([10, 10, 10], center=true);
"""
    
    def apply_modifications(self, scad_content, modification_prompt):
        """Use LLM to modify the SCAD code based on natural language"""
        system_prompt = """You are an expert OpenSCAD developer. 
When given OpenSCAD code and a modification request, respond with ONLY the modified OpenSCAD code.
Do not include explanations, markdown formatting, or code blocks - just the raw .scad code.
Ensure the code is valid OpenSCAD syntax."""

        user_prompt = f"""Current OpenSCAD code:
```
{scad_content}
```

Modification request: {modification_prompt}

Provide the complete modified OpenSCAD code:"""

        print("Sending request to LLM...")
        modified_code = self.llm_client.get_completion(system_prompt, user_prompt)
        
        # Clean up response (remove markdown if present)
        modified_code = modified_code.strip()
        if modified_code.startswith("```"):
            lines = modified_code.split('\n')
            modified_code = '\n'.join(lines[1:-1]) if len(lines) > 2 else modified_code
            modified_code = modified_code.replace("```openscad", "").replace("```", "").strip()
        
        return modified_code
    
    def save_scad(self, content, filename):
        """Save the modified SCAD file"""
        output_path = self.output_dir / f"{filename}.scad"
        print(f"Saving modified file to: {output_path}")
        with open(output_path, 'w') as f:
            f.write(content)
        return output_path
    
    def render_stl(self, scad_path, output_name):
        """Render STL from SCAD file using OpenSCAD"""
        stl_path = self.output_dir / f"{output_name}.stl"
        print(f"Rendering STL: {stl_path}")
        
        try:
            # Use xvfb-run to run OpenSCAD in headless mode
            cmd = [
                "xvfb-run", "-a",
                "openscad",
                "-o", str(stl_path),
                str(scad_path)
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode == 0:
                print(f"STL rendered successfully: {stl_path}")
                return stl_path
            else:
                print(f"OpenSCAD error: {result.stderr}")
                return None
                
        except subprocess.TimeoutExpired:
            print("Rendering timed out")
            return None
        except Exception as e:
            print(f"Error rendering STL: {e}")
            return None
    
    def process(self, input_file=None, modification=None):
        """Main processing pipeline"""
        # Step 1: Read or create SCAD file
        scad_content, base_name = self.read_or_create_scad(input_file)
        
        if scad_content is None and input_file:
            print("Error: Could not read input file")
            return False
        
        # Step 2: Apply modifications if requested
        if modification:
            print(f"Applying modification: {modification}")
            scad_content = self.apply_modifications(scad_content, modification)
        else:
            print("No modifications requested, using original/default content")
        
        # Step 3: Save modified SCAD
        output_name = f"{base_name}_modified" if modification else base_name
        scad_path = self.save_scad(scad_content, output_name)
        
        # Step 4: Render STL
        stl_path = self.render_stl(scad_path, output_name)
        
        if stl_path:
            print("\n=== Process Complete ===")
            print(f"SCAD file: {scad_path}")
            print(f"STL file: {stl_path}")
            return True
        else:
            print("\n=== Process Failed ===")
            return False


def main():
    """Main entry point"""
    # Get parameters from environment variables
    input_file = os.getenv("INPUT_FILE")  # e.g., "model.scad"
    modification = os.getenv("MODIFICATION")  # e.g., "Make it twice as large"
    
    print("=== OpenSCAD LLM Modifier ===")
    print(f"AI Provider: {os.getenv('AI_PROVIDER', 'openai')}")
    print(f"Input file: {input_file or 'None (creating new)'}")
    print(f"Modification: {modification or 'None'}")
    print()
    
    modifier = OpenSCADModifier()
    success = modifier.process(input_file, modification)
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
