<?php
// logger.php

/**
 * Write a log message to a file
 * 
 * @param string $message The log message
 * @param string $type Optional type: INFO, ERROR, WARNING
 * @param string $file Optional log file name
 */
function write_log($message, $type = 'INFO', $file = 'system_logs.log') {
    // Logs directory
    $logDir = __DIR__ . '/logs';
    
    // Create logs directory if it doesn't exist
    if (!file_exists($logDir)) {
        mkdir($logDir, 0777, true);
    }

    // Full file path
    $logFile = $logDir . '/' . $file;

    // Format message with timestamp
    $date = date('Y-m-d H:i:s');
    $logMessage = "[$date] [$type] $message" . PHP_EOL;

    // Append to file
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}
?>