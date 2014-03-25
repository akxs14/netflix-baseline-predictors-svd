import java.io.IOException;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.RecordWriter;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.MultipleInputs;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.mapreduce.InputSplit;

import com.eclipsesource.json.*;

public class ClicksImpressionsFilter {

	public static class Map extends Mapper<Text, Text, Text, Text> {

		private static int CLICK = 0;
		private static int IMPRESSION = 1;
		public static String rootFolder = "clicks_impressions";
		private static String inputRootFolder = "events";
		
		protected String filenameKey;
		private RecordWriter<Text, Text> writer;
		private JsonObject jsonObject;
		
		@Override
		public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
			jsonObject= JsonObject.readFrom(value.toString());
			int type = jsonObject.get("type").asInt();
			
			if(type == CLICK || type == IMPRESSION)
				writer.write(new Text(""), value);
		}
		
		@Override
		protected void setup(Context context) throws IOException, InterruptedException {

			
			
			
			
			InputSplit inputSplit = (InputSplit)context.getInputSplit();
			String sPath = inputSplit.toString();
			String[] sPathArray = sPath.split("/");

			int startIndex = getRootFolderIndex(sPathArray);
			final String sOutputFilePath = assembleOutputPath(startIndex,sPathArray);		
			
			TextOutputFormat<Text, Text> tof = new TextOutputFormat<Text, Text>() {
				@Override
				public Path getDefaultWorkFile(TaskAttemptContext context,
						String extension) throws IOException {
					return new Path(sOutputFilePath);
				}
			};
			writer = tof.getRecordWriter(context);
		}
		
		private String assembleOutputPath(int startIndex, String[] path) {
			String outPath  = "";
			String fileName = path[path.length-1].split(":")[0];
			
			for(int i=startIndex;i<path.length-1;i++) {
				if(i == startIndex)
					outPath += rootFolder + "/";
				else
					outPath += path[i] + "/";
			}
			outPath += fileName;
			return outPath;
		}
		
		private int getRootFolderIndex(String[] path) {
			int startIndex = 0;
			for(int i=0;i<path.length;i++) {
				if(path[i].equals(inputRootFolder)) {
					startIndex = i;
					break;
				}
			}
			return startIndex; 
		}
	}

	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		
		Job job = new Job(conf, "Clicks - Impressions Filter");
		
		job.setJarByClass(ClicksImpressionsFilter.class);
		
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		        
		job.setMapperClass(Map.class);
		        
//		job.setInputFormatClass(TextInputFormat.class);
		job.setOutputFormatClass(TextOutputFormat.class);

		String[] inputFiles = args[0].split(",");
		for(String inputFile : inputFiles)
			MultipleInputs.addInputPath(job, new Path(inputFile), TextInputFormat.class, Map.class);
			
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		        
		job.setNumReduceTasks(0);
		
		job.waitForCompletion(true);
	}	
}

