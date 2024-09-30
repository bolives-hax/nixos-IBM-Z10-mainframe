
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <fcntl.h>
#include <errno.h>

#define DEFAULT_TEST_FILE "io_test.tmp"
#define BUFFER_SIZE (1024 * 1024)  // 1 MB
#define SLEEP_INTERVAL 5           // Interval between tests in seconds

// Function to get the current timestamp as a string
void get_timestamp(char *buffer, size_t size) {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    strftime(buffer, size, "%Y-%m-%d %H:%M:%S", t);
}

// Function to convert bytes to a human-readable format (KB/s, MB/s, etc.)
void human_readable_speed(double bytes_per_sec, char *output, size_t size) {
    const char *units[] = {"B/s", "KB/s", "MB/s", "GB/s", "TB/s"};
    int unit = 0;
    while (bytes_per_sec >= 1024 && unit < 4) {
        bytes_per_sec /= 1024;
        unit++;
    }
    snprintf(output, size, "%.2f %s", bytes_per_sec, units[unit]);
}

// Function to test write speed
double test_write_speed(const char *test_file) {
    char *buffer = malloc(BUFFER_SIZE);
    if (!buffer) {
        perror("Unable to allocate buffer");
        exit(EXIT_FAILURE);
    }
    memset(buffer, 'A', BUFFER_SIZE);  // Fill buffer with dummy data

    int fd = open(test_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("Error opening test file for writing");
        free(buffer);
        exit(EXIT_FAILURE);
    }

    struct timeval start, end;
    gettimeofday(&start, NULL);  // Start the timer

    ssize_t total_bytes_written = 0;
    for (int i = 0; i < 100; i++) {  // Write 100 MB
        ssize_t bytes_written = write(fd, buffer, BUFFER_SIZE);
        if (bytes_written < 0) {
            perror("Error writing to test file");
            close(fd);
            free(buffer);
            exit(EXIT_FAILURE);
        }
        total_bytes_written += bytes_written;
    }

    gettimeofday(&end, NULL);  // End the timer
    close(fd);
    free(buffer);

    double elapsed_time = (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) / 1000000.0;
    return total_bytes_written / elapsed_time;  // Bytes per second
}

// Function to test read speed
double test_read_speed(const char *test_file) {
    char *buffer = malloc(BUFFER_SIZE);
    if (!buffer) {
        perror("Unable to allocate buffer");
        exit(EXIT_FAILURE);
    }

    int fd = open(test_file, O_RDONLY);
    if (fd < 0) {
        perror("Error opening test file for reading");
        free(buffer);
        exit(EXIT_FAILURE);
    }

    struct timeval start, end;
    gettimeofday(&start, NULL);  // Start the timer

    ssize_t total_bytes_read = 0;
    ssize_t bytes_read;
    while ((bytes_read = read(fd, buffer, BUFFER_SIZE)) > 0) {
        total_bytes_read += bytes_read;
    }

    if (bytes_read < 0) {
        perror("Error reading from test file");
        close(fd);
        free(buffer);
        exit(EXIT_FAILURE);
    }

    gettimeofday(&end, NULL);  // End the timer
    close(fd);
    free(buffer);

    double elapsed_time = (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) / 1000000.0;
    return total_bytes_read / elapsed_time;  // Bytes per second
}

// Main function to run the continuous I/O speed test
int main(int argc, char *argv[]) {
    const char *test_file = DEFAULT_TEST_FILE;  // Default test file path
    const char *log_file = NULL;                // Log file path (NULL means stdout)
    FILE *log_stream = stdout;

    // Parse command-line arguments
    if (argc > 1) {
        test_file = argv[1];  // First argument is the test file path
    }
    if (argc > 2) {
        log_file = argv[2];  // Second argument is the log file path
    }

    // If a log file path is provided, open it for writing
    if (log_file) {
        log_stream = fopen(log_file, "a");
        if (!log_stream) {
            perror("Error opening log file");
            exit(EXIT_FAILURE);
        }
    }

    fprintf(log_stream, "Starting I/O speed test...\n");

    while (1) {  // Continuous loop
        char timestamp[64];
        get_timestamp(timestamp, sizeof(timestamp));

        // Test write speed
        double write_speed = test_write_speed(test_file);
        char write_speed_str[32];
        human_readable_speed(write_speed, write_speed_str, sizeof(write_speed_str));

        // Test read speed
        double read_speed = test_read_speed(test_file);
        char read_speed_str[32];
        human_readable_speed(read_speed, read_speed_str, sizeof(read_speed_str));

        // Log the results with timestamp
        fprintf(log_stream, "[%s] Write Speed: %s | Read Speed: %s\n", timestamp, write_speed_str, read_speed_str);

        // Flush the log stream to ensure data is written immediately
        fflush(log_stream);

        // Sleep for the defined interval before running the test again
        sleep(SLEEP_INTERVAL);
    }

    // If we are logging to a file, close the log stream when done
    if (log_file) {
        fclose(log_stream);
    }

    return 0;
}

