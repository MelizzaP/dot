function speak_lines --description "Read specified lines from a file using text-to-speech"
    # Check if we have the right number of arguments
    if test (count $argv) -lt 3 -o (count $argv) -gt 4
        echo "Usage: speak_lines <filename> <start_line> <end_line> [rate]"
        return 1
    end

    set filename $argv[1]
    set start_line $argv[2]
    set end_line $argv[3]
    set rate 225

    # Use optional 4th argument for rate
    if test (count $argv) -eq 4
        set rate $argv[4]
    end

    # Resolve the full path
    set filepath (realpath $filename 2>/dev/null)
    if test $status -ne 0
        set filepath $filename
    end

    # Check if file exists
    if not test -f $filepath
        echo "Error: File '$filename' not found"
        return 1
    end

    # Use sed to extract lines and pipe to say
    sed -n "$start_line,$end_line p" $filepath | say -r $rate --progress --voice=Karen
end
