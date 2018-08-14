-- Proof of concept
INSERT INTO metric (metric_name, metric_value)
SELECT 'UnifiedBuild', 'true'
WHERE NOT EXISTS (SELECT c.metric_id FROM metric c WHERE c.metric_name = 'UnifiedBuild');

INSERT INTO metric (metric_name, metric_value)
SELECT 'CopySOShippingNotestoPO', 'true'
WHERE NOT EXISTS (SELECT c.metric_id FROM metric c WHERE c.metric_name = 'CopySOShippingNotestoPO');


