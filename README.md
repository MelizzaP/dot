# Cheat Sheet

| Command          | Action                                                                       | Mode           |
| ---------------- | ---------------------------------------------------------------------------- | -------------- |
| <LocalLeader>ws  | Clears extra whitespace                                                      | Normal, Visual |
| <LocalLeader>hws | Clears extra whitespace highlighting                                         | Normal, Visual |
| <LocalLeader>cc  | comments out current or selected lines                                       | Normal, Visual |
| s                | Fuzzy search through the output of git ls-files command, respects .gitignore | Normal         |
| <LocalLeader>gs  | Greps the filepath for the word under the cursor                             | Normal         |
| <LocalLeader>ff  | Lists files in your current working directory, respects .gitignore           | Normal         |
| <LocalLeader>s   | Goto the definition of the word under the cursor                             | Normal         |
| <LocalLeader>td  | Goto the type definition of the word under the cursor                        | Normal         |
| <LocalLeader>im  | Goto the implementation of the word under the cursor                         | Normal         |
| <LocalLeader>r   | Lists LSP references for word under the cursor                               | Normal         |
| <C-L>            | inserts fat arrow `=>`                                                       | Insert         |
| <C-S>            | inserts pipe `\|>`                                                           | Insert         |
| <C-F>            | insert emoji                                                                 | Insert         |
| <Tab>            | function completion via `omnifunc`                                           | Insert         |
| gd               | vim.lsp.buf.definition                                                       | Normal         |
| gD               | vim.lsp.buf.declaration                                                      | Normal         |
| K                | vim.lsp.buf.hover                                                            | Normal         |
| gi               | vim.lsp.buf.implementation                                                   | Normal         |
| gr               | vim.lsp.buf.references                                                       | Normal         |
| <C-k>            | vim.lsp.buf.signature_help                                                   | Normal         |
| <space>D         | vim.lsp.buf.type_definition                                                  | Normal         |
| <space>rn        | vim.lsp.buf.rename                                                           | Normal         |
| <space>f         | vim.lsp.buf.format                                                           | Normal         |
