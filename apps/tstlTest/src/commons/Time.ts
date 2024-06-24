///@ts-nocheck
export class DateTimeFormatter {
  static timeZoneOffset: number = 0;

  /**
   * Pads a number with leading zeros to a specified length.
   * @param num - The number to pad.
   * @param length - The target length of the string.
   * @returns The padded string.
   */
  static pad(num: number, length: number): string {
      let str = num.toString();
      while (str.length < length) {
          str = '0' + str;
      }
      return str;
  }

  /**
   * Converts epoch time to the most common German date-time format.
   * @param epochTime - The epoch time in milliseconds.
   * @returns The formatted date-time string in "DD.MM.YYYY HH:MM:SS" format.
   */
  static formatGermanDateTime(epochTime: number): string {
      const localTime = epochTime + DateTimeFormatter.timeZoneOffset;
      const seconds = Math.floor(localTime / 1000);
      const formattedDate = os.date("!*t", seconds);
      
      const day = DateTimeFormatter.pad(formattedDate.day, 2);
      const month = DateTimeFormatter.pad(formattedDate.month, 2);
      const year = formattedDate.year;
      const hours = DateTimeFormatter.pad(formattedDate.hour, 2);
      const minutes = DateTimeFormatter.pad(formattedDate.min, 2);
      const secondsStr = DateTimeFormatter.pad(formattedDate.sec, 2);
      
      return `${day}.${month}.${year} ${hours}:${minutes}:${secondsStr}`;
  }

  /**
   * Converts epoch time to ISO 8601 format.
   * @param epochTime - The epoch time in milliseconds.
   * @returns The formatted date-time string in "YYYY-MM-DDTHH:MM:SS.mmmZ" format.
   */
  static formatISO8601(epochTime: number): string {
      const localTime = epochTime + DateTimeFormatter.timeZoneOffset;
      const seconds = Math.floor(localTime / 1000);
      const milliseconds = DateTimeFormatter.pad(localTime % 1000, 3);
      const formattedDate = os.date("!*t", seconds);
      
      
      const year = formattedDate.year;
      const month = DateTimeFormatter.pad(formattedDate.month, 2);
      const day = DateTimeFormatter.pad(formattedDate.day, 2);
      const hours = DateTimeFormatter.pad(formattedDate.hour, 2);
      const minutes = DateTimeFormatter.pad(formattedDate.min, 2);
      const secondsStr = DateTimeFormatter.pad(formattedDate.sec, 2);
      
      return `${year}-${month}-${day}T${hours}:${minutes}:${secondsStr}.${milliseconds}Z`;
  }

  /**
   * Gets the current time in UTC.
   * @returns The current epoch time in milliseconds.
   */
  static getCurrentUTCTime(): number {
      return os.epoch("utc");
  }

  /**
   * Sets the time zone offset.
   * @param offset - The time zone offset in milliseconds.
   */
  static setTimeZoneOffset(offset: number): void {
      DateTimeFormatter.timeZoneOffset = offset;
  }
}