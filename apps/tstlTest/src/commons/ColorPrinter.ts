interface ColorsMap {
    [key: string]: number;
}

export class ColorPrinter {
    private static colorsMap: ColorsMap = {
        "0": colors.white,
        "1": colors.orange,
        "2": colors.magenta,
        "3": colors.lightBlue,
        "4": colors.yellow,
        "5": colors.lime,
        "6": colors.pink,
        "7": colors.gray,
        "8": colors.lightGray,
        "9": colors.cyan,
        "a": colors.purple,
        "b": colors.blue,
        "c": colors.brown,
        "d": colors.green,
        "e": colors.red,
        "f": colors.black,
    };

    /**
     * Prints a string with embedded color codes.
     * 
     * @param str The string to print with embedded color codes.
     */
    public static printColoredString(str: string): void {
        const setColor = (colorCode: number, isBackground: boolean): void => {
            if (isBackground) {
                term.setBackgroundColor(colorCode);
            } else {
                term.setTextColor(colorCode);
            }
        };

        const resetColors = (): void => {
            term.setTextColor(colors.white);
            term.setBackgroundColor(colors.black);
        };

        let [x, y] = term.getCursorPos();
        let i = 1;
        while (i <= str.length) {
            const char = str.charAt(i - 1);
            if (char === "&") {
                const nextChar = str.charAt(i);
                if (nextChar === "r") {
                    resetColors();
                    i += 2;
                } else if (ColorPrinter.colorsMap[nextChar]) {
                    setColor(ColorPrinter.colorsMap[nextChar], false);
                    i += 2;
                } else if (str.length >= i + 2 && ColorPrinter.colorsMap[nextChar] && ColorPrinter.colorsMap[str.charAt(i + 1)]) {
                    setColor(ColorPrinter.colorsMap[nextChar], false);
                    setColor(ColorPrinter.colorsMap[str.charAt(i + 1)], true);
                    i += 3;
                } else {
                    // Invalid sequence, print '&' and continue
                    term.setCursorPos(x, y);
                    term.write(char);
                    x += 1;
                    i += 1;
                }
            } else {
                term.setCursorPos(x, y);
                term.write(char);
                x += 1;
                i += 1;
            }
        }
    }

    /**
     * Prints a colored string followed by a newline.
     * 
     * @param str The string to print with embedded color codes.
     */
    public static printlnColoredString(str: string): void {
        ColorPrinter.printColoredString(str);
        print(""); // Print a newline
    }

    /**
     * Prints a string inline with color (overwriting current line).
     * 
     * @param str The string to print inline with color.
     */
    public static printInlineWithColor(str: string): void {
        const [x, y] = term.getCursorPos();
        term.setCursorPos(1, y); // Move cursor to beginning of the line
        term.clearLine(); // Clear the line
        ColorPrinter.printColoredString(str); // Print the colored string
    }
    public static writeColumns(left: string, middle: string, right: string): void {
        // Determine the width of each column
        const terminalWidth: number = term.getSize()[0]; // Adjust based on your terminal width or desired output width
        const columnWidth: number = Math.floor((terminalWidth - 2) / 3); // Subtract 2 for borders and divide by 3

        // Calculate the lengths of each part
        const leftLen: number = left.length;
        const middleLen: number = middle.length;
        const rightLen: number = right.length;
    
        // Calculate the available space for the right column
        let rightAvailableWidth: number = columnWidth - rightLen;
    
        // If middle column is empty, adjust right column width to fit within the terminal width
        if (middleLen === 0) {
            rightAvailableWidth = terminalWidth - leftLen - rightLen;
        }
    
        // Calculate the number of spaces needed for each column
        const leftSpaces: number = columnWidth - leftLen;
        const middleSpaces: number = columnWidth - middleLen;
        const rightSpaces: number = rightAvailableWidth;
    
        // Construct the formatted string with aligned columns 
        const formattedString: string =
            `${left}${" ".repeat(leftSpaces)}` +
            `${" ".repeat(Math.floor(middleSpaces / 2))}${middle}${" ".repeat(Math.ceil(middleSpaces / 2))}`
            ;

        // Output the formatted string     
        ColorPrinter.printlnColoredString(formattedString); // Assuming 'print' is a function available in your TypeScript environment for Lua output
        term.setCursorPos(terminalWidth-`${" ".repeat(rightSpaces)}${right}`.length + (`${" ".repeat(rightSpaces)}${right}`.split("&").length*2)-1, term.getSize()[1] - 1); 
        ColorPrinter.printlnColoredString(`${" ".repeat(rightSpaces)}${right}`); // Assuming 'print' is a function available in your TypeScript environment for Lua output
    }
}
