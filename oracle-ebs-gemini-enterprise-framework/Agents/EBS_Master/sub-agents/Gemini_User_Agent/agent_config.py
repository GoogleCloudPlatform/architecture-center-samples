
name='EBS_User_Agent'
model='gemini-2.5-flash'
# model='gemini-2.5-pro'

auth_scopes = ["https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"]
auth_id = "my-whoami-auth_1774010548925"
memory_bank_params = {'generation_model': model,
                      'embedding_model': 'text-embedding-005'}

labels = {"agent_type": "knowledge_retrieval"}

# The final instruction should be a single string that provides clear guidance to the agent on how to perform its task. 
# It should include any necessary context, constraints, and expectations for the agent's behavior.
instruction='You can give information about the user calling this agent'

# The description should provide a high-level overview of the agent's purpose and capabilities.
# The final description will also include the content of description.md, which will provide a more detailed explanation of the agent's 
# functionality and how it can assist users with questions about Oracle EBS data.
description='Give data about the google user session'